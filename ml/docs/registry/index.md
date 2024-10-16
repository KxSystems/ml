# Introduction

The _KX ML Registry Library_ contains functionality to create centralized registry locations for the storage of versioned machine learning models, workflows and advanced analytics, alongside parameters, metrics and other important artefacts. 

The ML Registry functionality, provided within the `.ml.registry` namespace in q, is intended to provide a key component in any MLOps stack built upon KX technology. Registries provide a location to which information required for model monitoring can be stored, retrained pipelines can be pushed and models for deployment can be retrieved.

The functionality aims to enhance our offering and provide users of kdb Insights with:

1. A method of introducing a users own models generated, with wrapped functionality allowing these models to be integrated seamlessly with specified limitations.
2. A method to understand stored models.
3. A single storage location for all `q/python models`.

## Sections

Documentation is broken into the following sections:

* [Registry API](api/setting.md)
* [Examples](examples/basic.md)
