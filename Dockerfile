FROM golang:alpine as builder
RUN adduser -D -g '' go
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates
WORKDIR /go/src/github.com/oscartbeaumont/dingo
RUN go get -u github.com/lucas-clemente/quic-go/h2quic
RUN go get -u golang.org/x/net/http2
RUN go get -u github.com/miekg/dns
COPY ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o dingo ./

FROM scratch
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /go/src/github.com/oscartbeaumont/dingo/dingo /
USER go
CMD ["/dingo"]
