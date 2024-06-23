
# Proyecto de Despliegue de Grafana en Kubernetes

Este proyecto tiene como objetivo desplegar la aplicación Grafana en un clúster de Kubernetes. A continuación se detallan los recursos y configuraciones utilizados para lograr este despliegue.

## Contenido del Proyecto

1. [PersistentVolumeClaim](#persistentvolumeclaim)
2. [Deployment](#deployment)
3. [ConfigMap](#configmap)
4. [Service](#service)
5. [Ingress](#ingress)

### PersistentVolumeClaim

El archivo `grafana-pvc.yaml` define una `PersistentVolumeClaim` para solicitar 2Gi de almacenamiento para Grafana.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-pvc
  namespace: grafana
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

### Deployment

El archivo `grafana-deployment.yaml` define un `Deployment` para desplegar un pod de Grafana usando la imagen `grafana/grafana:latest`. Además, monta un volumen persistente y un archivo de configuración desde un `ConfigMap`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: grafana
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config-volume
          mountPath: /etc/grafana/grafana.ini
          subPath: grafana.ini
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-pvc
      - name: grafana-config-volume
        configMap:
          name: grafana-config
          items:
          - key: grafana.ini
            path: grafana.ini
```

### ConfigMap

El archivo `grafana-config.yaml` define un `ConfigMap` contiene la configuración de autenticación de Grafana.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-config
  namespace: grafana 
data:
  grafana.ini: |
    [auth]
    # Configuración de usuario y contraseña de Grafana
    username = admin
    password = Secreto1!
```

### Service

El archivo `grafana-service.yaml` define un `Service` de tipo `LoadBalancer` para exponer la aplicación Grafana en el puerto 80 y redirigir el tráfico al puerto 3000 del pod.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
  namespace: grafana
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 3000
  selector:
    app: grafana
```

### Ingress

El archivo `grafana-ingress.yaml` define un `Ingress` para gestionar el acceso a la aplicación Grafana a través del host `grafana.local`.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: grafana
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: grafana.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana-service
            port:
              number: 80
```

## Pasos para Desplegar

1. **Crear el namespace**:
    ```bash
    kubectl create namespace grafana
    ```

2. **Crear la PersistentVolumeClaim**:
    ```bash
    kubectl apply -f grafana-pvc.yaml
    ```

3. **Crear el ConfigMap**:
    ```bash
    kubectl apply -f grafana-config.yaml
    ```

4. **Crear el Deployment**:
    ```bash
    kubectl apply -f grafana-deployment.yaml
    ```

5. **Crear el Service**:
    ```bash
    kubectl apply -f grafana-service.yaml
    ```

6. **Crear el Ingress**:
    ```bash
    kubectl apply -f grafana-ingress.yaml
    ```

## Consideraciones Finales

- Asegurarse de tener un Ingress Controller (como NGINX Ingress Controller) desplegado en nuestro clúster para manejar las reglas del Ingress.
- Configurar el DNS para que `grafana.local` apunte a la dirección IP del Ingress Controller o agregar una entrada en el archivo `hosts` de la maquina en la que estemos probando para resolver `grafana.local` a la dirección IP del clúster o del Ingress Controller.
- Revisar los logs del pod de Grafana si encuentras problemas durante el despliegue usando:
    ```bash
    kubectl logs -n grafana -l app=grafana
    ```

Con estos pasos y configuraciones, lograremos tener Grafana desplegado y accesible en nuestro clúster de Kubernetes.
