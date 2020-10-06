class classifier(nn.Module):

    def __init__(self,input_dim, hidden_dim, dropout = 0.4):
        super().__init__()

        self.fc1 = nn.Linear(input_dim, hidden_dim)
        self.fc2 = nn.Linear(hidden_dim, hidden_dim)
        self.fc3 = nn.Linear(hidden_dim, 1)
        self.dropout = nn.Dropout(p = dropout)


    def forward(self,x):
        x = self.dropout(F.relu(self.fc1(x)))
        x = self.dropout(F.relu(self.fc2(x)))
        x = self.fc3(x)

        return x 

def runmodel(model,optimizer,criterion,dataloader,n_epoch):
    for epoch in range(n_epoch):
        train_loss=0
        for idx, data in enumerate(dataloader, 0):
            inputs, labels = data
            model.train()
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs,labels.view(-1,1))
            loss.backward()
            optimizer.step()
            train_loss += loss.item()/len(dataloader)
    return model