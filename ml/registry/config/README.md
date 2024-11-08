# Config

This section of the repository contains all information relating to predefined configuration needed for setting models/experiments to the registry and deploying models. All configuration should be written as JSON dictionaries which can be parsed by `.j.k`. At present there are two distinct configurations being defined within this section of the repository.

1. `command-line.json` - Default information relating to command line retrieval of the model and how data being passed to these models should be managed.
2. `default.json` - Default model information and definition of how by default model versions are to be incremented.
3. `model.json` - Basic model information used to define model behaviour and monitoring configuration.
