package pod

import (
	"encoding/json"

	v1 "k8s.io/api/core/v1"
	"pellep.io/webhook/pkg/mutate"
)

// NewValidationHook creates a new instance of pods validation hook
func NewValidationHook() mutate.Hook {
	return mutate.Hook{
		Create: validateCreate(),
	}
}

// NewMutationHook creates a new instance of pods mutation hook
func NewMutationHook() mutate.Hook {
	return mutate.Hook{
		Create: mutateCreate(),
	}
}

func parsePod(object []byte) (*v1.Pod, error) {
	var pod v1.Pod
	if err := json.Unmarshal(object, &pod); err != nil {
		return nil, err
	}

	return &pod, nil
}
