package ui

import (
	"embed"
	"io/fs"
	"net/http"

	log "github.com/sirupsen/logrus"
)

/*
Can add this below to add multiple include statements to content
//go:embed image/* template/*
*/

// content holds our static web server content.
//
//go:embed public/index.html
var content embed.FS

func Serve(listenAddress string) {
	sub, err := fs.Sub(content, "public")
	if err != nil {
		panic(err)
	}

	mux := http.NewServeMux()
	mux.Handle("/", http.FileServer(http.FS(sub)))

	log.Infof("listening on %q", listenAddress)
	if err := http.ListenAndServe(listenAddress, mux); err != nil {
		panic(err)
	}
}
