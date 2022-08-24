FROM golang:1.18-alpine as builder
ADD . /src
WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o movie-catalogue .
FROM alpine
COPY --from=builder /src/movie-catalogue /usr/local/bin/movie-catalogue
WORKDIR /usr/local/bin
EXPOSE 8081
ENTRYPOINT [ "./movie-catalogue" ]