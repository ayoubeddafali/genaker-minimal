# Minimal Magento Cloud Infrastructure 

![Minimal Magento Terraform](https://user-images.githubusercontent.com/9213670/134946402-8a4ff61d-5def-448a-83dd-89eadecaa550.png)

## Pre-requis

1. Terraform
2. Terragrunt

Pour installer les version adéquates, lancer le script install-terraform.sh sur votre machine locale.

## Configuration d'accés au compte AWS

A partir de la console, exporter les cles d'APIS, et configurer les variables d'environments suivantes :
```
$ export AWS_DEFAULT_REGION=us-east-2
$ export AWS_ACCESS_KEY_ID=...
$ export AWS_SECRET_ACCESS_KEY=...
```


## Déploiement d'infrastructure

Pour déployer l'infrastructure minimale de Genaker, il suffit de lancer :

```
$ cd magento-cloud-minimal/production
$ terragrunt run-all apply
```

Aprés confirmation, l'infra doit etre prete dans 5 minutes max.
Vous ne devez pas avoir de problémes de terraform/modules si vous utiliser la branche minimale, et les pre-requies.


## Supressions de l'infrastructure


```
 terragrunt run-all destroy
```

## Configuration de magento

Pour configurer magento sur les VMs créer, vous pouvez suivre le script `install-magento.sh`.

Le script fait les actions suivantes: 

- Lignes 6 -> 11 : Installation du php8.2 et ses modules
- Lignes 15 -> 18 :Installation de composer
- Lignes 20 -> 22 :Installation de Nginx
- Lignes 24 -> 26 :Installer des utilitaires : le client de mysql et redis pour tester la connexion en ligne de commande
- Lignes 28 -> 31 :Configuration de php-fpm pour utiliser l'utilisateur nginx au lieu du apache
- Lignes 33 -> 38 :Installation du OpenMage
- Lignes 47 -> 81 :Configuration de nginx pour magento 1
- Lignes 87 -> 100 :Installation du sample data
- Lignes 101 -> 106 :Permissions
- Lignes 108 -> 111 : Redémarrage du service


Noter la présence de la variable DB_HOST, cette variable doit etre modifiée avant la configuration de magento. Vous devez changer la valeur de la variable par celle presente lorsque vous visiter AWS Console -> RDS, et vous cliquer sur la base crée par terraform, et vous inspecter les details pour avoir le host.

## Test 

Une fois le script est terminé, vous devez etre capable a accéder à l'instance de Magento à partir de l'IP public de la VM.

## References

* [Terraform documentation](https://www.terraform.io/docs/) and [Terragrunt documentation](https://terragrunt.gruntwork.io/docs/) for all available commands and features
* [Terraform AWS modules](https://github.com/terraform-aws-modules/)
* [Terraform modules registry](https://registry.terraform.io/)
* [Terraform best practices](https://www.terraform-best-practices.com/)


