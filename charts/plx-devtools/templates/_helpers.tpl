{{- define "plx-devtools.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "plx-devtools.selectorLabels" -}}
app.kubernetes.io/name: {{ include "plx-devtools.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "plx-devtools.labels" -}}
{{ include "plx-devtools.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/* repository@digest; refuses to render without a digest. */}}
{{- define "plx-devtools.image" -}}
{{- $digest := required "image.digest is required: images are deployed by digest only" .Values.image.digest -}}
{{- if not (regexMatch "^sha256:[a-f0-9]{64}$" $digest) -}}
{{- fail (printf "image.digest %q is not a sha256 digest" $digest) -}}
{{- end -}}
{{- printf "%s@%s" .Values.image.repository $digest -}}
{{- end -}}
