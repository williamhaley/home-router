package main

import (
	"flag"
	"log"
	"os"
	"text/template"

	"gopkg.in/yaml.v3"
)

type AccessPoint struct {
	SSID       string `yaml:"ssid"`
	Passphrase string `yaml:"passphrase"`
}

type DHCP struct {
	Range        string `yaml:"range"`
	InternalCIDR string `yaml:"internal_cidr"`
	Hosts        string `yaml:"hosts"`
}

type DNS struct {
	UpstreamIP string `yaml:"upstream_ip"`
	Hosts      string `yaml:"hosts"`
}

type Config struct {
	RouterIP       string `yaml:"router_ip"`
	SubnetMask     string `yaml:"subnet_mask"`
	LANInterface   string `yaml:"lan_interface"`
	WLANInterface  string `yaml:"wlan_interface"`
	WANInterface   string `yaml:"wan_interface"`
	PortForwarding []struct {
		SourcePort         int    `yaml:"source_port"`
		DestinationAddress string `yaml:"destination_address"`
		DestinationPort    string `yaml:"destination_port"`
	} `yaml:"port_forwarding"`
	AccessPoint *AccessPoint `yaml:"access_point"`
	DHCP        *DHCP        `yaml:"dhcp"`
	DNS         *DNS         `yaml:"dns"`
	DDNS        struct {
		Login    string `yaml:"login"`
		Password string `yaml:"password"`
		Domain   string `yaml:"domain"`
	} `yaml:"ddns"`
}

var templatePath string
var configPath string
var outputPath string
var isShowingDefaults bool

func init() {
	flag.StringVar(&templatePath, "t", "", "Path to a template file")
	flag.StringVar(&configPath, "c", "/config/home-router.yaml", "Path to a config file")
	flag.StringVar(&outputPath, "o", "", "Path to output file")
	flag.BoolVar(&isShowingDefaults, "h", false, "Print this help info")
	flag.Parse()

	if isShowingDefaults || templatePath == "" {
		flag.PrintDefaults()
		os.Exit(1)
	}
}

func main() {
	var config Config

	if configFile, err := os.ReadFile(configPath); err != nil {
		panic(err)
	} else {
		if err := yaml.Unmarshal([]byte(configFile), &config); err != nil {
			log.Fatalf("error: %v", err)
		}

		if templateFile, err := template.ParseFiles(templatePath); err != nil {
			panic(err)
		} else if outputPath != "" {
			outputFile, err := os.Create(outputPath)
			if err != nil {
				log.Fatal(err)
			}
			defer outputFile.Close()

			if err := templateFile.Execute(outputFile, config); err != nil {
				panic(err)
			}
		} else if err := templateFile.Execute(os.Stdout, config); err != nil {
			panic(err)
		}
	}
}
