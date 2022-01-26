package pod

import (
	"strings"

	"k8s.io/api/admission/v1beta1"
	v1 "k8s.io/api/core/v1"
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
		var operations []mutate.PatchOperation
		pod, err := parsePod(r.Object.Raw)
		if err != nil {
			return &mutate.Result{Msg: err.Error()}, nil
		}

		// Very simple logic to inject a new "sidecar" container.
		if pod.Namespace == "special" {
			var containers []v1.Container
			containers = append(containers, pod.Spec.Containers...)
			sideC := v1.Container{
				Name:    "test-sidecar",
				Image:   "busybox:stable",
				Command: []string{"sh", "-c", "while true; do echo 'I am a container injected by mutating webhook'; sleep 2; done"},
			}
			containers = append(containers, sideC)
			operations = append(operations, mutate.ReplacePatchOperation("/spec/containers", containers))
		}

		// Add a simple annotation using `AddPatchOperation`
		metadata := map[string]string{"origin": "fromMutation"}
		operations = append(operations, mutate.AddPatchOperation("/metadata/annotations", metadata))
		return &mutate.Result{
			Allowed:  true,
			PatchOps: operations,
		}, nil
	}
}
