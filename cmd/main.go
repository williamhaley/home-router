package main

import (
	"flag"
	"fmt"
	"home-router/ui"
	"os"

	"github.com/BurntSushi/toml"
)

type Config struct {
	ListenAddress string `toml:"ListenAddress"`
}

var config *Config

var configPath string
var isShowingDefaults bool
var listenAddress = ""

func init() {
	flag.StringVar(&configPath, "c", "/etc/home-router/home-router.conf", "Path to a config file")
	flag.BoolVar(&isShowingDefaults, "h", false, "Print this help info")
	flag.Parse()

	if isShowingDefaults {
		flag.PrintDefaults()
		os.Exit(1)
	}

	_, err := toml.DecodeFile(configPath, &config)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if envListenAddress, ok := os.LookupEnv("LISTEN_ADDRESS"); ok {
		listenAddress = envListenAddress
	} else {
		listenAddress = config.ListenAddress
	}
}

func main() {
	ui.Serve(listenAddress)
}
