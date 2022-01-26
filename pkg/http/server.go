package http

import (
	"fmt"
	"net/http"

	"pellep.io/webhook/pkg/types/deployment"
	"pellep.io/webhook/pkg/types/pod"
)

// NewServer creates and return a http.Server
func NewServer(port string) *http.Server {
	// Instances hooks
	podsValidation := pod.NewValidationHook()
	podsMutation := pod.NewMutationHook()
	deploymentValidation := deployment.NewValidationHook()

	// Routers
	ah := newAdmissionHandler()
	mux := http.NewServeMux()
	mux.Handle("/healthz", healthz())
	mux.Handle("/validate/pods", ah.Serve(podsValidation))
	mux.Handle("/mutate/pods", ah.Serve(podsMutation))
	mux.Handle("/validate/deployments", ah.Serve(deploymentValidation))

	return &http.Server{
		Addr:    fmt.Sprintf(":%s", port),
		Handler: mux,
	}
}
