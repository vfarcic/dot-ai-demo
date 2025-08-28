#!/usr/bin/env nu

source scripts/kubernetes.nu
source scripts/common.nu
source scripts/crossplane.nu
source scripts/ingress.nu
source scripts/mcp.nu
source scripts/anthropic.nu
source scripts/kyverno.nu

def main [] {}

def "main setup" [
    --dot-ai-tag: string = "latest",
    --qdrant-run: bool = true,
    --qdrant-tag: string = "latest"
] {
    
    rm --force .env

    # let provider = main get provider --providers ["azure" "google"]

    let anthropic_data = main get anthropic

    mut openai_key = ""
    if "OPENAI_API_KEY" in $env {
        $openai_key = $env.OPENAI_API_KEY
    } else {
        let value = input $"(ansi green_bold)Enter OpenAI API key:(ansi reset) "
        $openai_key = $value
    }

    let qdrant_image = $"ghcr.io/vfarcic/dot-ai-demo/qdrant:($qdrant_tag)"
    let dot_ai_image = $"ghcr.io/vfarcic/dot-ai:($dot_ai_tag)"

    $"export OPENAI_API_KEY=($openai_key)\n" | save --append .env
    $"export QDRANT_IMAGE=($qdrant_image)\n" | save --append .env
    $"export DOT_AI_IMAGE=($dot_ai_image)\n" | save --append .env

    docker image pull $qdrant_image

    docker image pull $dot_ai_image

    if not $qdrant_run {(
        docker container run --detach --name qdrant
            --publish 6333:6333 $qdrant_image
    )}

    main create kubernetes kind

    cp kubeconfig-dot.yaml kubeconfig.yaml

    main apply ingress nginx --provider kind

    main apply crossplane --app-config true --db-config true

    main apply kyverno

    kubectl create namespace a-team

    kubectl create namespace b-team

    kubectl apply --filename k8s/

    main print source

}

def "main destroy" [] {

    main destroy kubernetes kind

    docker container rm qdrant --force

}

def "main build-image" [version: string] {
    
    let repo = "ghcr.io/vfarcic/dot-ai-demo/qdrant"
    
    print "Extracting data from running Qdrant container..."
    
    # Remove existing qdrant_storage directory if it exists at root
    if (ls . | where name == "qdrant_storage" and type == "dir" | length) > 0 {
        rm --recursive --force qdrant_storage
    }
    
    # Extract data from the running Qdrant container to root directory
    docker container cp qdrant:/qdrant/storage ./qdrant_storage
    
    # Verify the data was extracted successfully
    if (ls . | where name == "qdrant_storage" and type == "dir" | length) == 0 {
        error "Failed to extract qdrant_storage from container"
    }
    
    print $"Building qdrant image with version ($version)..."
    docker image build --file Dockerfile-qdrant --build-arg $"VERSION=($version)" --tag $"($repo):($version)" --tag $"($repo):latest" .
    
    print "Cleaning up extracted data files..."
    rm --recursive --force qdrant_storage
    
    print $"Pushing qdrant image..."
    docker image push $"($repo):($version)"
    docker image push $"($repo):latest"
    
    print $"Image pushed successfully: ($repo):($version) and ($repo):latest"
}
