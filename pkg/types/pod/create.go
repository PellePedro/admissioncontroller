package pod

import (
	"fmt"
	"strings"

	"k8s.io/api/admission/v1beta1"
	v1 "k8s.io/api/core/v1"
	log "k8s.io/klog/v2"
	"pellep.io/webhook/pkg/mutate"
)

func validateCreate() mutate.AdmitFunc {
	return func(r *v1beta1.AdmissionRequest) (*mutate.Result, error) {
		pod, err := parsePod(r.Object.Raw)
		if err != nil {
			return &mutate.Result{Msg: err.Error()}, nil
		}

		for _, c := range pod.Spec.Containers {
			if strings.HasSuffix(c.Image, ":latest") {
				return &mutate.Result{Msg: "You cannot use the tag 'latest' in a container."}, nil
			}
		}
		return &mutate.Result{Allowed: true}, nil
	}
}

func mutateCreate() mutate.AdmitFunc {
	return func(r *v1beta1.AdmissionRequest) (*mutate.Result, error) {
		log.Info("Executing mutateCreate function")
		fmt.Println("Executing mutateCreate function")
		var operations []mutate.PatchOperation
		pod, err := parsePod(r.Object.Raw)
		if err != nil {
			return &mutate.Result{Msg: err.Error()}, nil
		}

		// Simple logic to inject a new "sidecar" container.
		if pod.Namespace == "magic" {
			var containers []v1.Container
			containers = append(containers, pod.Spec.Containers...)
			sideC := v1.Container{
				Name:    "test-sidecar",
				Image:   "busybox:stable",
				Command: []string{"sh", "-c", "while true; do echo 'Sidecar container injected by mutating webhook'; sleep 2; done"},
			}
			containers = append(containers, sideC)
			operations = append(operations, mutate.ReplacePatchOperation("/spec/containers", containers))
		}

		// Add a simple annotation using `AddPatchOperation`
		log.Info("Adding Patch Operation matadata/labels")
		metadata := map[string]string{"origin": "tsf-controller"}
		operations = append(operations, mutate.AddPatchOperation("/metadata/labels", metadata))
		return &mutate.Result{
			Allowed:  true,
			PatchOps: operations,
		}, nil
	}
}

func init() {
	fmt.Println("Pod Creation hook")
}
