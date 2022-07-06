# MPS Reporting

### To Start Local Dev Server
```
$ rails s
```

### To Test
```
$ rspec test
$ rake test
```


### DevOps

To test helm chart
```
$ cd devops/pbie
$ helm template --debug . -f ../overrides.yaml
```


docker build -f Dockerfile.aci .