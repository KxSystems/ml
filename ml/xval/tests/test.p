p)def kfsplit(x,y):
        from sklearn.model_selection import KFold
        kf=KFold(n_splits=y)
        split=kf.split(x)
        return list(split)

p)def kfoldr(x,y):
        from sklearn.model_selection import cross_val_score
        from sklearn.linear_model import ElasticNet
        clf = ElasticNet()
        scores = cross_val_score(clf,x,y,cv=3)
        return scores
        
p)def kfoldc(x,y):
        from sklearn.model_selection import cross_val_score
        from sklearn.tree import DecisionTreeClassifier
        clf = DecisionTreeClassifier()
        scores = cross_val_score(clf,x,y,cv=3)
        return scores

p)def crossvalr(x,y,z,k,m):
        from sklearn.linear_model import LinearRegression
        model=LinearRegression()
        lst=[]
        import numpy as np
        a=np.array(x)
        b=np.array(y)
        for i in range(m-1): 
                sx=[a[j] for j in z[i]]
                sy=[b[j] for j in z[i]]
                model.fit (sx,sy)
                sx1=[a[n] for n in k[i]]
                sy1=[b[n] for n in k[i]]
                score=model.score(sx1,sy1)
                lst.append(score)
        return lst
        
p)def crossvalc(x,y,z,k,m):
        from sklearn.tree import DecisionTreeClassifier
        model=DecisionTreeClassifier()
        lst=[]
        import numpy as np
        a=np.array(x)
        b=np.array(y)
        for i in range(m-1): 
                sx=[a[j] for j in z[i]]
                sy=[b[j] for j in z[i]]
                model.fit (sx,sy)
                sx1=[a[n] for n in k[i]]
                sy1=[b[n] for n in k[i]]
                score=model.score(sx1,sy1)
                lst.append(score)
        return lst

p)def gridsearchr(x,y):
        from sklearn.model_selection import GridSearchCV
        from sklearn.linear_model import ElasticNet
        regr = ElasticNet()
        param={'max_iter':(100,200,1000),'alpha':(0.1,0.2)}
        clf=GridSearchCV(regr, param,cv=3)
        clf.fit(x,y)
        acc=clf.best_score_
        p=clf.best_params_
        return(acc, p)

p)def gridsearchc(x,y):
        from sklearn.model_selection import GridSearchCV
        from sklearn.tree import DecisionTreeClassifier
        clf = DecisionTreeClassifier()
        param={'max_depth':(None,1,2,3,4,5)}
        clf=GridSearchCV(clf, param,cv=3)
        clf.fit(x,y)
        acc=clf.best_score_
        p=clf.best_params_
        return (acc, p)

p)def fitscore(xtrain,ytrain,xtest,ytest):
        from sklearn.linear_model import ElasticNet
        regr = ElasticNet()
        regr.fit(xtrain, ytrain)
        score = regr.score(xtest,ytest)
        return score
