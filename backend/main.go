// Command dummy-backend is a maximally simple demo backend.
//
// It has ZERO knowledge of leak-checking, k-anonymity, or the
// caddy-hansestack plugin sitting in front of it. That is the point of the
// demo: security is decoupled into the reverse proxy layer, and the backend
// stays completely ignorant of it. It just serves a static page and always
// "succeeds" a login.
package main

import (
	"encoding/json"
	"log"
	"net/http"
)

// loginRequest mirrors the JSON body the demo frontend sends to /login.
// The password is only ever logged as "[redacted]" — never in plaintext.
type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "index.html")
	})

	mux.HandleFunc("POST /login", handleLogin)

	addr := ":80"
	log.Printf("dummy-backend listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}

// handleLogin always succeeds. There is no database, no password check, no
// leak-check logic here — all of that already happened (or didn't) in
// Caddy before this handler was ever invoked.
func handleLogin(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid JSON body", http.StatusBadRequest)
		return
	}

	log.Printf("login request received: email=%q password=[redacted]", req.Email)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_, _ = w.Write([]byte(`{"status":"created"}`))
}
