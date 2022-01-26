package deployment

import (
	"encoding/json"

	v1 "k8s.io/api/apps/v1"
	"pellep.io/webhook/pkg/mutate"
)

// NewValidationHook creates a new instance of deployment validation hook
func NewValidationHook() mutate.Hook {
	return mutate.Hook{
		Create: validateCreate(),
		Delete: validateDelete(),
	}
}

func parseDeployment(object []byte) (*v1.Deployment, error) {
	var dp v1.Deployment
	if err := json.Unmarshal(object, &dp); err != nil {
		return nil, err
	}

	return &dp, nil
}
