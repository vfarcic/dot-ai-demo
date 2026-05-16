#!/usr/bin/env nu

# Installs DevOps AI Toolkit with MCP server support and controller
#
# Examples:
# > main apply dot-ai --host dot-ai.127.0.0.1.nip.io
# > main apply dot-ai --provider openai --model gpt-4o
# > main apply dot-ai --enable-tracing true
def "main apply dot-ai" [
    --anthropic-api-key = "",
    --openai-api-key = "",
    --auth-token = "",
    --provider = "anthropic",
    --model = "claude-haiku-4-5-20251001",
    --ingress-enabled = true,
    --ingress-class = "nginx",
    --host = "dot-ai.127.0.0.1.nip.io",
    --version = "0.140.0",
    --controller-version = "0.49.0",
    --enable-tracing = false
] {

    let anthropic_key = if ($anthropic_api_key | is-empty) {
        $env.ANTHROPIC_API_KEY? | default ""
    } else {
        $anthropic_api_key
    }

    let openai_key = if ($openai_api_key | is-empty) {
        $env.OPENAI_API_KEY? | default ""
    } else {
        $openai_api_key
    }

    let token = if ($auth_token | is-empty) {
        let env_token = $env.DOT_AI_AUTH_TOKEN? | default ""
        if ($env_token | is-empty) {
            openssl rand -base64 32 | str trim
        } else {
            $env_token
        }
    } else {
        $auth_token
    }

    $"export DOT_AI_AUTH_TOKEN=($token)\n" | save --append .env

    let tracing_flags = if $enable_tracing {
        [
            --set 'extraEnv[0].name=OTEL_TRACING_ENABLED'
            --set-string 'extraEnv[0].value=true'
            --set 'extraEnv[1].name=OTEL_EXPORTER_OTLP_ENDPOINT'
            --set 'extraEnv[1].value=http://jaeger-collector.observability.svc.cluster.local:4318/v1/traces'
            --set 'extraEnv[2].name=OTEL_SERVICE_NAME'
            --set 'extraEnv[2].value=dot-ai-mcp'
        ]
    } else {
        []
    }

    (
        helm upgrade --install dot-ai-controller
            $"oci://ghcr.io/vfarcic/dot-ai-controller/charts/dot-ai-controller:($controller_version)"
            --namespace dot-ai --create-namespace
            --wait
    )

    (
        helm upgrade --install dot-ai-mcp
            $"oci://ghcr.io/vfarcic/dot-ai/charts/dot-ai:($version)"
            --set $"secrets.anthropic.apiKey=($anthropic_key)"
            --set $"secrets.openai.apiKey=($openai_key)"
            --set $"secrets.auth.token=($token)"
            --set $"ai.provider=($provider)"
            --set $"ai.model=($model)"
            --set $"ingress.enabled=($ingress_enabled)"
            --set $"ingress.className=($ingress_class)"
            --set $"ingress.host=($host)"
            --set "controller.enabled=true"
            ...$tracing_flags
            --namespace dot-ai --create-namespace
            --wait
    )

    print $"DevOps AI Controller (ansi yellow_bold)($controller_version)(ansi reset) installed in (ansi yellow_bold)dot-ai(ansi reset) namespace"
    print $"DevOps AI Toolkit is available at (ansi yellow_bold)http://($host)(ansi reset)"

    if $enable_tracing {
        print $"Tracing enabled: Traces will be sent to (ansi yellow_bold)Jaeger in observability namespace(ansi reset)"
    }

}
