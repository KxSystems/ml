import numpy as np
import torch


class LinearNNModel(torch.nn.Module):
    def __init__(self):
        super(LinearNNModel, self).__init__()
        self.linear = torch.nn.Linear(1, 1)  # One in and one out

    def forward(self, x):
        y_pred = self.linear(x)
        return y_pred


def gen_data():
    # Example linear model modified to use y = 2x
    # from https://github.com/hunkim/PyTorchZeroToAll
    # X training data, y labels
    x = torch.arange(1.0, 25.0).view(-1, 1)
    y = torch.from_numpy(np.array([val.item() * 2 for val in x]).astype('float32')).view(-1, 1)
    return x, y


# Define model, loss, and optimizer
model = LinearNNModel()
criterion = torch.nn.MSELoss()
optimizer = torch.optim.SGD(model.parameters(), lr=0.001)

# Training loop
epochs = 250
x, y = gen_data()
for _epoch in range(epochs):
    # Forward pass: Compute predicted y by passing X to the model
    y_pred = model(x)

    # Compute the loss
    loss = criterion(y_pred, y)

    # Zero gradients, perform a backward pass, and update the weights.
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()

m = torch.jit.script(LinearNNModel())
m.save("tests/torch.pt")
