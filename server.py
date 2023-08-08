import sys
import shutil
import glob
from http.server import BaseHTTPRequestHandler
from http.server import ThreadingHTTPServer
import os
import json
import traceback
import roop.core
import roop.face_analyser
from roop.processors.frame import face_swapper
import roop.globals
import threading
import cv2
import numpy as np
from roop import utilities
from tqdm import tqdm

def extract_frames(input_path: str,output_dir:str, fps: float = 30) -> bool:
    temp_frame_quality = roop.globals.temp_frame_quality * 31 // 100
    utilities.run_ffmpeg(['-hwaccel', 'auto', '-i', input_path, '-q:v', str(temp_frame_quality), '-pix_fmt', 'rgb24', '-vf', 'fps=' + str(fps), os.path.join(output_dir, '%04d.' + roop.globals.temp_frame_format)])

def create_gif(input_frames_dir,fps, output_path):
    input_frames_dir=os.path.join(input_frames_dir,"%04d.png")
    utilities.run_ffmpeg(['-hwaccel', 'auto', '-f', 'image2', '-r', str(fps), '-i', input_frames_dir,output_path])

def create_video(input_frames_dir, fps, output_path):
    output_dir = os.path.join(input_frames_dir, '%04d.' + roop.globals.temp_frame_format)
    output_video_quality = (roop.globals.output_video_quality + 1) * 51 // 100
    commands = ['-hwaccel', 'auto',
                '-r', str(fps),
                '-i', output_dir,
                '-vf', "pad=ceil(iw/2)*2:ceil(ih/2)*2",
                '-c:v', roop.globals.output_video_encoder]
    if roop.globals.output_video_encoder in ['libx264', 'libx265', 'libvpx']:
        commands.extend(['-crf', str(output_video_quality)])
    if roop.globals.output_video_encoder in ['h264_nvenc', 'hevc_nvenc']:
        commands.extend(['-cq', str(output_video_quality)])
    commands.extend(['-pix_fmt', 'yuv420p', '-vf', 'colorspace=bt709:iall=bt601-6-625:fast=1', '-y', output_path])
    return utilities.run_ffmpeg(commands)

def add_audio(video_path:str,audio_path: str, output_path: str) -> bool:
    return utilities.run_ffmpeg(['-hwaccel', 'auto', 
                                 '-i', video_path, 
                                 '-i', audio_path, 
                                 '-c:v', 'copy', 
                                 '-map', '0:v:0',
                                 '-map', '1:a:0',
                                 '-y', output_path])

def get_most_similar_face(faces, face_to_find,min_similarity):
    target_face_embedding = face_to_find.embedding
    max_similarity=-1000
    max_similarityFace=None
    norm_b = np.linalg.norm(target_face_embedding)
    # Compare faces
    for face in faces:
        # Calculate facial similarity
        similarity = np.dot(face.embedding, target_face_embedding)
        # Calculate vector norm
        norm_a = np.linalg.norm(face.embedding)
        # Calculate cosine similarity
        similarity = similarity / (norm_a * norm_b)
        if similarity>max_similarity:
            max_similarity=similarity
            max_similarityFace=face
    if max_similarity>=min_similarity:
        return max_similarityFace
    return None

class JsonCustomEncoder(json.JSONEncoder): 
    def default(self, field): 
        if isinstance(field, np.ndarray): 
            return field.tolist()
        elif isinstance(field, np.floating): 
            return field.tolist()
        elif isinstance(field, np.integer): 
            return field.tolist()
        else: 
            return json.JSONEncoder.default(self, field)

def cv2imread(file_path):
    cv_img=cv2.imdecode(np.fromfile(file_path,dtype=np.uint8),-1)
    return cv_img

def process_frames(source_faces,target_faces,frame_paths,output_dir, progress,min_similarity):
    for frame_path in frame_paths:
        frame = cv2imread(frame_path)
        try:
            result = process_one_frame(source_faces,target_faces, frame,min_similarity)
            cv2.imwrite(os.path.join(output_dir,os.path.split(frame_path)[-1]), result)
        except Exception as exception:
            print(exception)
            pass
        if progress:
            progress.update(1)

def process_one_frame(source_faces,target_faces,frame,min_similarity):
    frame_faces=roop.face_analyser.get_many_faces(cv2.cvtColor(frame,cv2.COLOR_RGB2BGR))
    result=frame
    if frame_faces is not None and len(frame_faces)>0:
        ser=face_swapper.get_face_swapper()
        for i in range(len(target_faces)):
            face=get_most_similar_face(frame_faces,target_faces[i],min_similarity)
            if face:
                result = ser.get(result, face, source_faces[i], paste_back=True)
    return result

def multi_process_frame(source_faces,target_faces,frame_paths,output_dir, progress,min_similarity):
    threads = []
    num_threads = roop.globals.execution_threads
    num_frames_per_thread = len(frame_paths) // num_threads
    remaining_frames = len(frame_paths) % num_threads

    # create thread and launch
    start_index = 0
    for _ in range(num_threads):
        end_index = start_index + num_frames_per_thread
        if remaining_frames > 0:
            end_index += 1
            remaining_frames -= 1
        thread_frame_paths = frame_paths[start_index:end_index]
        thread = threading.Thread(target=process_frames, args=(source_faces,target_faces,thread_frame_paths,output_dir, progress,min_similarity))
        threads.append(thread)
        thread.start()
        start_index = end_index

    # threading
    for thread in threads:
        thread.join()
    
def process_video(source_faces,target_faces,frame_paths,output_dir,min_similarity):
    do_multi = roop.globals.execution_threads > 1
    progress_bar_format = '{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, {rate_fmt}{postfix}]'
    with tqdm(total=len(frame_paths), desc="Processing", unit="frame", dynamic_ncols=True, bar_format=progress_bar_format) as progress:
        if do_multi:
            multi_process_frame(source_faces,target_faces,frame_paths,output_dir, progress,min_similarity)
        else:
            process_frames(source_faces,target_faces,frame_paths,output_dir, progress,min_similarity)

class MyHTTPHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        code=-1
        evalResult=None
        errMsg=None
        try:
            print("[Request]",post_data)
            evalResult=eval("self.func_"+post_data)
            code=0
        except Exception as err:
            traceback.print_exc()
            errMsg=str(err)
            code=-2
        self.send_response(200)
        self.send_header('Content-type', 'application/json;charset:utf-8')
        self.end_headers()
        result={
            "code":code,
            "errMsg":errMsg,
            "result":evalResult
        }
        print("[Response]",result)
        resultStr=json.dumps(result,cls=JsonCustomEncoder)
        self.wfile.write(resultStr.encode('utf-8'))
    
    def func_get_faces(self,input_img_path):
        t=roop.face_analyser.get_many_faces(cv2.cvtColor(cv2imread(input_img_path),cv2.COLOR_RGB2BGR))
        return t
    
    def func_swap_video(self,source_face_infos,target_face_infos,target_path,output_path,keep_fps,min_similarity):
        video_name_full = os.path.split(target_path)[-1]
        video_name = os.path.splitext(video_name_full)[0]
        temp_output_dir = os.path.join(os.path.dirname(target_path),"faceswap_temp",video_name)
        if os.path.exists(temp_output_dir):
            shutil.rmtree(temp_output_dir)
        os.makedirs(temp_output_dir,exist_ok=True)
        print("detecting video's FPS...")
        fps = utilities.detect_fps(target_path)
        if not keep_fps:
            fps=30
        print(f'Extracting frames with {fps} FPS...')
        extract_frames(target_path,temp_output_dir,fps)
        frame_paths = tuple(sorted(
            glob.glob(os.path.join(temp_output_dir,"*.png")),
            key=lambda x: int(os.path.splitext(os.path.split(x)[-1])[0])
        ))
        
        source_cache={}
        source_faces=[]
        for i in range(len(source_face_infos)):
            info=source_face_infos[i]
            if info["file"] in source_cache:
                source_img_faces=source_cache[info["file"]]
            else:
                source_img=cv2.cvtColor(cv2imread(info["file"]),cv2.COLOR_RGB2BGR)
                source_img_faces=roop.face_analyser.get_many_faces(source_img)
                source_cache[info["file"]]=source_img_faces
            source_faces.append(source_img_faces[info["face"]])
        target_cache={}
        target_faces=[]
        for i in range(len(target_face_infos)):
            info=target_face_infos[i]
            if info["file"] in target_cache:
                target_img_faces=target_cache[info["file"]]
            else:
                target_img=cv2.cvtColor(cv2imread(info["file"]),cv2.COLOR_RGB2BGR)
                target_img_faces=roop.face_analyser.get_many_faces(target_img)
                target_cache[info["file"]]=target_img_faces
            target_faces.append(target_img_faces[info["face"]])
        frames_temp_dir = os.path.join(os.path.dirname(temp_output_dir),video_name+"_swapped")
        if os.path.exists(frames_temp_dir):
            shutil.rmtree(frames_temp_dir)
        os.makedirs(frames_temp_dir,exist_ok=True)
        process_video(source_faces,target_faces,frame_paths,frames_temp_dir,min_similarity)
        if video_name_full.endswith(".gif"):
            print("creating gif...")
            create_gif(frames_temp_dir,fps,output_path)
        else:
            print("creating video...")
            temp_output_path=os.path.join(frames_temp_dir,"tempvideo.mp4")
            create_video(frames_temp_dir, fps, temp_output_path)
            print("adding audio...")
            add_audio(temp_output_path, target_path, output_path)
        return 'succ'
    
    def func_video_screenshot(self,duration,input_path,output_path):
        if utilities.run_ffmpeg(['-hwaccel','auto', '-ss' ,str(duration),'-i',input_path,'-r','1','-vframes','1','-an','-vcodec','mjpeg','-y',output_path]):
            return 'succ'
        return 'fail'

    def func_swap_image(self,source_face_infos,target_face_indexs,target_img_path,output_file):
        source_cache={}
        target_img = cv2imread(target_img_path)
        all_target_faces=roop.face_analyser.get_many_faces(cv2.cvtColor(target_img,cv2.COLOR_RGB2BGR))
        result=target_img
        if all_target_faces is not None and len(all_target_faces)>0:
            ser=face_swapper.get_face_swapper()
            for i in range(len(source_face_infos)):
                info=source_face_infos[i]
                if info["file"] in source_cache:
                    source_img_faces=source_cache[info["file"]]
                else:
                    source_img=cv2.cvtColor(cv2imread(info["file"]),cv2.COLOR_RGB2BGR)
                    source_img_faces=roop.face_analyser.get_many_faces(source_img)
                    source_cache[info["file"]]=source_img_faces
                source_face=source_img_faces[info["face"]]
                target_face=all_target_faces[target_face_indexs[i]]
                result = ser.get(result, target_face, source_face, paste_back=True)
        cv2.imwrite(output_file, result)
        print("\n\nImage saved as:", output_file, "\n\n")
        return 'succ'


def run(server_class=ThreadingHTTPServer,
        handler_class=MyHTTPHandler,
        port=0,
        bind='127.0.0.1'):
    with server_class((bind, port), handler_class) as httpd:
        if port==0:
            _,port=httpd.socket.getsockname()
        print(f"Serving HTTP on http://{bind}:{port}/")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nKeyboard interrupt received, exiting.")
            sys.exit(0)


if __name__ == '__main__':
    if len(sys.argv)>1:
        port=int(sys.argv[1])
        sys.argv.pop(0)
    else:
        port=53499
    roop.core.parse_args()
    roop.globals.log_level='debug'
    if not roop.core.pre_check():
        exit(1)
    if not face_swapper.pre_check():
        exit(1)
    roop.core.limit_resources()
    run(port=port)