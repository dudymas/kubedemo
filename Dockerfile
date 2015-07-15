FROM golang:1.5

COPY server.go /srv/server.go

CMD [ "go", "run", "/srv/server.go" ]

EXPOSE 8080
