# Kubernetes – Exercice

Il existe différentes possibilités d’installation locale de Kubernetes.
On retrouve typiquement **Minikube**, **Kind** ou encore via **Docker Desktop**.

Pour cet exercice, nous allons installer Kubernetes via **Docker Desktop**.

---

## 1. Activer Kubernetes sur Docker Desktop

1. Ouvrez **Docker Desktop**
2. Allez dans **Settings**
3. Cliquez sur **Enable Kubernetes**
4. Dans l’onglet **Kubernetes**, section **Cluster settings** :

   * Choisissez **kind**
   * **1 node**
   * Version **1.31.1**
5. Cliquez sur **Apply**
6. Attendez la fin de l’installation (cela peut prendre quelques minutes)

---

## 2. Ajouter les routes `health` et `break`

Ces routes permettent d’interagir avec le **liveness probe** de Kubernetes.

### Exemple de code (Flask)

```python
healthy = True

@main.route("/health", methods=['GET'])
def health():
    if healthy:
        return jsonify(status="ok"), 200
    else:
        return jsonify(status="error"), 500


@main.route("/break", methods=['GET'])
def break_app():
    global healthy
    healthy = False
    return "Health probe will now fail", 200
```

---

## 3. Monter une image Docker

### Créer l’image

Créez le `Dockerfile` si vous n’en avez pas.

```bash
docker build -t <nom_utilisateur_DockerHub>/<nom_image>:latest .
```

L’image **n’a pas besoin d’être lancée** avec `docker run` ou Docker Desktop, car elle sera lancée par Kubernetes.

> Remarque :
>
> * L’image est créée dans le moteur Docker local (Windows)
> * Le nœud Kubernetes tourne sur une VM Linux
> * Cette VM dispose de son propre Docker daemon, isolé de celui de Windows

### Pousser l’image sur Docker Hub

```bash
docker push <nom_utilisateur_DockerHub>/<nom_image>:latest
```

L’image est maintenant disponible sur **Docker Hub**, ce qui permet à Kubernetes d’y accéder.

---

## 4. Créer un fichier de déploiement

Nommez le fichier :

```text
<nom_application>-deployment.yaml
```

### Exemple de fichier `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: <nom_application>-deployment

spec:
  replicas: 2
  selector:
    matchLabels:
      app: <nom_application>
  template:
    metadata:
      labels:
        app: <nom_application>
    spec:
      containers:
        - name: <nom_application>
          image: <nom_utilisateur_DockerHub>/<nom_image>:latest
          ports:
            - containerPort: 80

          livenessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
```

### Appliquer le déploiement

```bash
kubectl apply -f <nom_application>-deployment.yaml
```

---

## 5. Créer un fichier de service

Nommez le fichier :

```text
<nom_application>-service.yaml
```

Ce fichier permet d’exposer l’application via un **Service de type LoadBalancer**, afin d’y accéder via l’adresse IP d’un nœud et un port.

### Appliquer le service

```bash
kubectl apply -f <nom_application>-service.yaml
```

---

## 6. Accéder à l’application

Ouvrez un navigateur et accédez à :

```text
http://localhost:8003
```

---

## 7. Simuler des erreurs

### Supprimer un pod manuellement

```bash
kubectl delete pod <nom_pod>
```

Effets observés :

* Le pod disparaît
* Le ReplicaSet détecte une réplique manquante
* Un nouveau pod est créé automatiquement

---

### Forcer un crash du conteneur

```bash
kubectl exec -it <nom_pod> -- sh
kill 1
```

Effets observés :

* Simulation d’un crash applicatif
* Kubernetes redémarre automatiquement le conteneur

---

### Simuler un liveness probe défaillant

1. Visiter :

   ```text
   /break
   ```
2. Puis :

   ```text
   /health
   ```

   (retourne une erreur **500**)

Effets observés :

* Kubernetes détecte des échecs répétés
* Kubernetes **kill et redémarre** le conteneur automatiquement
