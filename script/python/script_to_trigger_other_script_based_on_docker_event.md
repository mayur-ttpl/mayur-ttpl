import docker
import subprocess
import time

def execute_shell_script():
    # Execute the shell script
    subprocess.run(["/bin/bash", "/root/test/script/test.sh"])

def listen_to_docker_events():
    # Connect to the Docker daemon
    client = docker.from_env()

    # Start listening to Docker events
    events = client.events(decode=True)

    # Loop to continuously listen for Docker events
    for event in events:
        # Check if the event is a new image creation event (either pull or create)
        if event.get('Type') == 'image' and (event.get('Action') == 'pull' or event.get('Action') == 'tag'):
            # Introduce a delay of 30 seconds
            time.sleep(30)
            # If a new image is created, execute the shell script
            execute_shell_script()

if __name__ == "__main__":
    # Start listening to Docker events
    listen_to_docker_events()

