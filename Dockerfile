FROM demo42upstream.azurecr.io/library/node:9-alpine
WORKDIR /test
COPY ./test.sh .
CMD ./test.sh
#ENTRYPOINT ["/bin/sh", "./test.sh"]
