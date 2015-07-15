package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Println("serving request!")
		fmt.Fprintf(w, "Hello, Kubernetes!")
	})

	log.Println("I am serving on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
