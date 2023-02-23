namespace :docker do
  namespace :build do
    task :base do
      cmd = %q(
        docker buildx build
          --platform="linux/amd64,linux/arm64"
          -t ghcr.io/houseninjadojo/api-base:latest
          -f platform/docker/Dockerfile.builder
          -o type=image
          .
      ).squish
      %x(#{cmd})
    end

    task :intermediate do
      cmd = %q(
        docker buildx build
          --platform="linux/amd64,linux/arm64"
          -t ghcr.io/houseninjadojo/api-intermediate:latest
          -f platform/docker/Dockerfile.intermediate
          -o type=image
          .
      ).squish
      %x(#{cmd})
    end

    task :all do
      Rake::Task["docker:build:base"].invoke
      Rake::Task["docker:build:intermediate"].invoke
      Rake::Task["docker:build"].invoke
    end
  end

  task :build do
    cmd = %q(
      docker buildx build
        --platform=linux/amd64,linux/arm64
        -t ghcr.io/houseninjadojo/api:latest
        -f Dockerfile
        -o type=image
        .
    ).squish
    %x(#{cmd})
  end

  namespace :push do
    task :base do
      cmd = %q(
        docker push ghcr.io/houseninjadojo/api-base:latest
      ).squish
      %x(#{cmd})
    end

    task :intermediate do
      cmd = %q(
        docker push ghcr.io/houseninjadojo/api-intermediate:latest
      ).squish
      %x(#{cmd})
    end

    task :all do
      Rake::Task["docker:push:base"].invoke
      Rake::Task["docker:push:intermediate"].invoke
      Rake::Task["docker:push"].invoke
    end
  end

  task :push do
    cmd = %q(
      docker push ghcr.io/houseninjadojo/api:latest
    ).squish
    %x(#{cmd})
  end
end
