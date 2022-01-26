package deployment

import (
	"k8s.io/api/admission/v1beta1"
	"pellep.io/webhook/pkg/mutate"
)

func validateDelete() mutate.AdmitFunc {
	return func(r *v1beta1.AdmissionRequest) (*mutate.Result, error) {
		dp, err := parseDeployment(r.OldObject.Raw)
		if err != nil {
			return &mutate.Result{Msg: err.Error()}, nil
		}

		if dp.Namespace == "special-system" && dp.Annotations["skip"] == "false" {
			return &mutate.Result{Msg: "You cannot remove a deployment from `special-system` namespace."}, nil
		}

		return &mutate.Result{Allowed: true}, nil
	}
}
