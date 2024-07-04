##https://github.com/Supervisor/supervisor/issues/935
[supervisord]
nodaemon=true

[program:main]
command=python main.py
autostart=true
autorestart=true
stderr_logfile=/dev/stderr
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes = 0
stderr_logfile_maxbytes = 0

[program:music_client_runner]
command=python music_client_runner.py
autostart=true
autorestart=true
stderr_logfile=/dev/stderr
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes = 0
stderr_logfile_maxbytes = 0

[program:musicians]
command=python musicians.py
autostart=true
autorestart=true
stdout_logfile=/app/musicians.log
stderr_logfile=/app/musicians.log
stdout_logfile_maxbytes = 0
stderr_logfile_maxbytes = 0
