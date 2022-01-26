package deployment

import (
	"k8s.io/api/admission/v1beta1"
	"pellep.io/webhook/pkg/mutate"
)

func validateCreate() mutate.AdmitFunc {
	return func(r *v1beta1.AdmissionRequest) (*mutate.Result, error) {
		dp, err := parseDeployment(r.Object.Raw)
		if err != nil {
			return &mutate.Result{Msg: err.Error()}, nil
		}

		if dp.Namespace == "special" {
			return &mutate.Result{Msg: "You cannot create a deployment in `special` namespace."}, nil
		}

		return &mutate.Result{Allowed: true}, nil
	}
}
