chcp 65001>nul
call C:\ProgramData\miniconda3\Scripts\activate.bat C:\ProgramData\miniconda3
call conda activate roop
pushd G:\github\roop\roop_github\
python -u server.py %1
pause
popd
echo errorlevel:%errorlevel%
exit