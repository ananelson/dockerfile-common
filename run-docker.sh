set -e
docker build -t ananelson/testcommon .
docker run -t -i \
    -v `pwd`:/home/repro/work \
    ananelson/testcommon /bin/bash
