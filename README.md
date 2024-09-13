A quick Dockerfile to build an image containing the free-threaded python 3.13 with no GIL and additionally with JIT enabled. [Based on](https://github.com/abebus/free-threaded-python-docker-image). The latest version in pyenv at the time of writing is `3.13.0rc2`

## Pull
```bash
docker pull gehirndienst/python-nogil-jit:latest
```

## Run
The repo provides a simple test script that demonstrates the difference between the GIL and no GIL. The script is copied to the image at `/home/test.py`. To run the script in the container, use the following command:

```bash
docker run -it --rm --name python-nogil-test gehirndienst/python-nogil-jit:latest bash -c "cd /home && python test.py && python -X gil=1 test.py && exec bash"
```


