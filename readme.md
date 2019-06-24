## This repository is created with learning purposes for Terraform, focusing on how to move an already created resource into a separate module and use TFE remote state for it.

## Purpose :

- It provides a simple example of how to use `terraform state mv` command to move existing resource to a separate module and then use TFE remote state.

## How to install terraform : 

- The information about installing terraform can be found on the HashiCorp website 
[here](https://learn.hashicorp.com/terraform/getting-started/install.html)

## How to use it :

- In a directory of your choice, clone the github repository :
    ```
    git clone https://github.com/martinhristov90/tfeMoveState.git
    ```
- Change into the directory :
    ```
    cd tfeMoveState
    ```
- Run `terraform init` to download the needed providers and `terraform apply` to create the resources described in the `main.tf`. Your output should look like:
    ```
    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create

    Terraform will perform the following actions:

      + null_resource.hello
          id:        <computed>

      + random_pet.name
          id:        <computed>
          length:    "4"
          separator: "-"


    Plan: 2 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.

      Enter a value: yes

    random_pet.name: Creating...
      length:    "" => "4"
      separator: "" => "-"
    random_pet.name: Creation complete after 0s (ID: supposedly-miserably-optimal-raptor)
    null_resource.hello: Creating...
    null_resource.hello: Provisioning with 'local-exec'...
    null_resource.hello (local-exec): Executing: ["/bin/sh" "-c" "echo Hello supposedly-miserably-optimal-raptor"]
    null_resource.hello (local-exec): Hello supposedly-miserably-optimal-raptor
    null_resource.hello: Creation complete after 0s (ID: 6725223686421428936)
    ```
- Now, the resource `random_pet.name` is going to be moved to a separate module. For this purpose,file `main.tf` is needs to be changed to :
    ```
    module "example" {
      source = "github.com/martinhristov90/tfeMoveStateModule?ref=v0.0.1"
    }

    resource "null_resource" "hello" {
      provisioner "local-exec" {
        command = "echo Hello ${module.example.display}"
      }
    }
    ```
- Now, you need to run `terraform init` to get the content of the `example` module. If `terraform plan` is run, terraform is going to suppose that we want to remove resource `random_pet.name` that was originally crated and we want to create new one `module.example.random_pet.name`. For Terraform those are two completely different resources, but to us they are the same. So, to move the state of `random_pet.name` resource, we need to use `terraform state mv random_pet.name module.example`. After executing this command Terraform knows that resource is moved to `module.example`. Output should look like this :
    ```
    Moved random_pet.name to module.example
    ```
- After moving the state of the `random_pet.name` resource, you can run `terraform plan` and see that no changes are needed. Output should look like this :
    ```
    random_pet.name: Refreshing state... (ID: supposedly-miserably-optimal-raptor)
    null_resource.hello: Refreshing state... (ID: 6725223686421428936)

    ------------------------------------------------------------------------

    No changes. Infrastructure is up-to-date.

    This means that Terraform did not detect any differences between your
    configuration and real physical resources that exist. As a result, no
    actions need to be performed.
    ```
## Moving the state file to TFE.
- Create, a new GitHub repository and link it with TFE workspace, push the newly modified TF code to it.
```shell
git remote -v # Review you have only one remote repo named "origin"
git add remote repoTFE URL_OF_YOUR_GITHUB_REPO_THAT_IS_CONNECTED_TO_TFE_WORKSPACE # Adding your remote repository.
git remote -v # Review you have two remotes
git checkout -b addContent  # To checkout into new branch named "addContent"
git add . # To stage all the files
git commit -m "Adding initial content to repoTFE" # Initial commit
git push repoTFE addContent # Pushing "addContent" branch to remote GitHub repo "repoTFE" which is connected to TFE workspace.
```
- TFE is going to execute `plan` on it, and it would like to create two new resources, that is because, TFE does not have the current state file.

- Get your user token by going to [here](https://app.terraform.io/app/settings/tokens) and enter a description, what the token is going to be used for, for example "exerciseToken" and click `generate`, copy the string.
- Enter the token as environment variable:
```shell
export ATLAS_TOKEN=YOUR_TOKEN_HERE
```
- Now, add the following section to `main.tf` and substitute the values for `organization` and `workspace`.
```
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "YOUR_ORGANIZAITON"

    workspaces {
      name = "YOUR_WORKSPACE"
    }
  }
}
```
- Execute `terraform init`. Terraform is going to ask you if you want to change the location of the `state` file, the output should look like this :
```
terraform init
Initializing modules...
- module.example

Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "atlas" backend. No existing state was found in the newly
  configured "atlas" backend. Do you want to copy this state to the new "atlas"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes


Successfully configured the backend "atlas"! Terraform will automatically
use this backend unless the backend configuration changes.
```
- Now, when the TFE executes plan, it is going to be in sync with the `state` file that has been already created locally, and represents the already created resources.

- To destroy the created resources, you should execute :
    ```
    terraform destroy
    ```
