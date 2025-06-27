Utilisation du script GetUniqPermFolderFromExport.ps1.
1- Télécharger le script dans un dossier
2- En tant que admin@iqonehc.com aller sur le site https://iqonehc.sharepoint.com/sites/iQoneDoc/_layouts/15/siteanalytics.aspx?view=19
3- En bas de la page, cliquer sur le lien Run report, stocker le résultat dans le SharePoint dans Tebicom
4- Télécharger le résultat dans le même dossier que le script
5- Démarrer PowerShell (as an admin si module Microsoft.Entra à installer)
6- Si ce n'est déjà fait, installer le module Microsoft.Entra (Install-Module Microsoft.Entra)
7- Dans PowerShell, se placer dans le dossier contenant script et fichier de rapport (cd …)
8- lancer le script .\GetUniqPermFolderFromExport.ps1 (nécessite éventuellement un set-executionpolicy remotesigned)
9- à la demande de connexion, se connnecter avec le compte admin@iqonehc.com
10- Récupérer le fichier généré iQoneRights.csv et le transférer à iQone