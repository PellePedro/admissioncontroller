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

		if dp.Namespace == "forbidden" {
			return &mutate.Result{Msg: "Cannot create a deployment in `forbidden` namespace."}, nil
		}

		return &mutate.Result{Allowed: true}, nil
	}
}
