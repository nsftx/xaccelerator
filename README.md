# XAccelerator 

XAccelerator is a packaged nginx preconfigured to handle X-Accel-Redirect responses and offload static file download from the main service.
It can dowload from many different storage options, any which has a publicly accessible URL. It can also handle auth using Bearer token which is configured at the backend. 

## Installation

Helm is used for installation. Helm deployes the Deployment, Service and ConfigMap used for configuring the backend service. 
All is configured via Values : 
```
replicaCount: 1
image:
  repository: quay.io/volatilemolotov/xaccelerator
  tag: 0.0.1
  pullPolicy: Always
nameOverride: ""
fullnameOverride: ""

service:
  type: ClusterIP
  port: 80

config:
  backend: "http://helloworld-go"

    
resources: {}

nodeSelector: {}

tolerations: []

affinity: {}
```
Where `backend` will be used to generate the configmap which is mounted to the nginx pod. 

## Usage example

Here is an example go app that serves as a backend. 

```
package main


import (
	"fmt"
	"net/http"
	"strings"
)

var fileSize string
var fileType string
var fileName string
var fileUrl string

func main() {
	fileUrl = "https://path_to_file/file"
	subStringsSlice := strings.Split(fileUrl, "/")
	fileName = subStringsSlice[len(subStringsSlice)-1]

	r, err := http.Head(fileUrl)
	if err != nil {
		fmt.Println(err)
	}

	fileSize = r.Header.Get("Content-Length")
	fileType = r.Header.Get("Content-Type")


	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":8080", nil) // set listen port
}

func HelloServer(rw http.ResponseWriter, req *http.Request) {
	rw.Header().Set("Content-Type", fileType)
	rw.Header().Set("Content-Length", fileSize)
	rw.Header().Set("Content-Disposition", "attachment; filename=" + fileName)
	rw.Header().Set("X-Accel-Redirect", "/accelerator/" + fileUrl)
	rw.Header().Set("X-Auth", "Bearer ya29.c.El9KB_ojFVVziv1zjzS-5gzdjnU_BZSML61drj62Yfvt5Inx5oTMTFDjfojKn1HhXmngZ9bSaNYWFkr3ZQUh2pxUYIG69NuuJveqxsXPOUTg397CyEcfxwN8Bqy6mK9bKA")

	rw.WriteHeader(http.StatusOK)
}

```

X-Accel-Redirect works by stripping `X-Accel-Redirect` and `X-Auth` headers from respones (These headers are not provided by the client in the request but are provided by the backend via response) and using the link provided to begin the download proxy using `X-Auth` as a auth token. Backend shoud handle the auth of the user and can log the download but the file is proxied through the accelerator.  `X-Accel-File-Url` and `X-Accel-File` are used for designating file location or url respectively. Path in `X-Accel-Redirect` will determine is the dowload local or remote URL. 