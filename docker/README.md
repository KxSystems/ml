The instructions below are for building your own Docker image. A prebuilt Docker image is available on Docker Cloud, if you only want to run the ml toolkit image then install Docker and [read the instructions on the main page](../README.md#docker) on how to do this.

## Preflight

You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version.

Check out a copy of the project with:

```bash
git clone https://github.com/KxSystems/ml.git
```

## Building

To build the project locally you run:

```bash
docker build -t ml -f docker/Dockerfile .
```

Once built, you should have a local `ml toolkit` image, you can run the following to use it:

```bash
docker run -it ml
```

**N.B.** if you wish to use an alternative source for [embedPy](https://github.com/KxSystems/embedPy) then you can append `--build-arg embedpy_img=embedpy` to your argument list.

Other build arguments are supported and you should browse the `Dockerfile` to see what they are.

# Deploy

[travisCI](https://travis-ci.org/) is configured to monitor when tags of the format `/^[0-9]+\./` are added to the [GitHub hosted project](https://github.com/KxSystems/ml), a corresponding Docker image is generated and made available on [Docker Cloud](https://cloud.docker.com/)

This is all done server side as the resulting image is large.

To do a deploy, you simply tag and push your releases as usual:

```bash
git push
git tag 0.7
git push --tag
```

## Related Links

 * [Docker](https://docker.com)
     * [`Dockerfile`](https://docs.docker.com/engine/reference/builder/)
