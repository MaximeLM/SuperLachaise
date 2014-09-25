#!/usr/bin/env python
# -*- coding: utf-8  -*-

"""
Parcourt les images commons du fichier database/PLData.json et télécharge les images requis depuis wikimedia commons,
en utilisant les dimensions de l'appareil client passées en paramètre.
"""

import os,sys

import urllib,urllib2
import json
import re
import time, datetime
import codecs

class MyError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

log_file = None
def log(text):
    print text
    if log_file:
        log_file.write(text+'\n')

licence_file = None
def licence(text):
    if licence_file:
        licence_file.write(text+'\n')

def requete_ratio_image(nom_image):
    """ Télécharge et calcule le ratio largeur/hauteur de l'image indiquée. """
    
    # URL de recherche sur l'API wikimedia
    url = "http://commons.wikimedia.org/w/api.php?action=query&titles=File:%s&prop=imageinfo&iiprop=size&format=json" % (urllib2.quote(nom_image.encode('utf8')))
    
    # Exécution de la requête
    req = urllib2.Request(url, headers={"User-Agent" : "download_images_common.py extraction tool lm.maxime@gmail.com"})
    u = urllib2.urlopen(req)
    
    # Recopie du résultat json dans un dictionnaire
    htmltext=u.read()
    balise = json.loads(htmltext)
    
    # Extraction des images
    
    if not balise.has_key('query'):
        raise MyError(u'query absent du résultat')
    balise = balise['query']
    
    if not balise.has_key('pages'):
        raise MyError(u'query.pages absent du résultat')
    balise = balise['pages']
    
    if not len(balise.keys()) == 1:
        raise MyError(u'query.pages ne contient pas un élément unique')
    balise = balise[balise.keys()[0]]
    
    if not balise.has_key('imageinfo'):
        raise MyError(u'query.pages.imageinfo absent du résultat')
    balise = balise['imageinfo']
    
    if not len(balise) == 1:
        raise MyError(u'query.pages.imageinfo ne contient pas un élément unique')
    balise = balise[0]
    
    largeur = float(balise[u'width'])
    hauteur = float(balise[u'height'])
    
    return largeur/hauteur

def requete_url_image(nom_image,size_argument):
    """ Télécharge l'url de l'image indiquée. """
    
    # URL de recherche sur l'API wikimedia
    url = "http://commons.wikimedia.org/w/api.php?action=query&titles=File:%s&prop=imageinfo&iiprop=url&%s&format=json" % (urllib2.quote(nom_image.encode('utf8')),size_argument)
    
    # Exécution de la requête
    req = urllib2.Request(url, headers={"User-Agent" : "download_images_common.py extraction tool lm.maxime@gmail.com"})
    u = urllib2.urlopen(req)
    
    # Recopie du résultat json dans un dictionnaire
    htmltext=u.read()
    balise = json.loads(htmltext)
    
    # Extraction des images
    
    if not balise.has_key('query'):
        raise MyError(u'query absent du résultat')
    balise = balise['query']
    
    if not balise.has_key('pages'):
        raise MyError(u'query.pages absent du résultat')
    balise = balise['pages']
    
    if not len(balise.keys()) == 1:
        raise MyError(u'query.pages ne contient pas un élément unique')
    balise = balise[balise.keys()[0]]
    
    if not balise.has_key('imageinfo'):
        raise MyError(u'query.pages.imageinfo absent du résultat')
    balise = balise['imageinfo']
    
    if not len(balise) == 1:
        raise MyError(u'query.pages.imageinfo ne contient pas un élément unique')
    balise = balise[0]
    
    if not balise.has_key('thumburl'):
        raise MyError(u'query.pages.imageinfo.thumburl absent du résultat')
    balise = balise['thumburl']
    
    return balise

def download_images(largeur, output, data):
    """ Parcourt les images commons.
    Télécharge les images en fonction des règles définies. """
    
    # Compteurs
    images_requete = 0
    images_erreur = 0
    images_downloaded = 0
    
    log(u"--> Parcours des monuments")
    for monument in data:
        if monument['image_principale']:
            # Récupération de l'image principale
            image = monument['image_principale']
        
            images_requete = images_requete + 1
        
            try:
                # Récupération du ratio de taille de l'image
                ratio = requete_ratio_image(image['nom'])
                
                if ratio < 1.0:
                    # Format vertical
                    size_argument = u'iiurlwidth=%s' % largeur
                else:
                    # Format horizontal
                    size_argument = u'iiurlheight=%s' % largeur
                
                # Récupération de l'url de téléchargement
                url = requete_url_image(image['nom'], size_argument)
                
                # Ajout de la licence dans le fichier texte
                licence(u'-> %s' % image['nom'])
                licence(u'%s / Wikimedia Commons / %s' % (image['auteur'],image['licence']))
                licence(u'http://commons.wikimedia.org/wiki/File:%s' % urllib2.quote(image['nom'].encode('utf-8')))
                licence(u'')
                
                # Téléchargement de l'image
                log(u'Téléchargement de %s' % image['nom'])
                urllib.urlretrieve(url, u'%s/%s' % (output,image['nom']))
                
                images_downloaded = images_downloaded + 1
            
            except MyError as e:
                log(u'=>Erreur : %s pour l\'image %s' % (e.value,unicode(image)))
                images_erreur = images_erreur + 1
    
    return {u'images_requete': images_requete, 
            u'images_erreur': images_erreur,
            u'images_downloaded': images_downloaded}

if __name__ == "__main__":
    
    # Création du fichier de log
    file_name = os.path.dirname(os.path.realpath(__file__)) + "/log_download_images_commons" + time.strftime("%Y-%m-%d_%H-%M-%S") + ".txt"
    log_file = codecs.open(file_name, "w", "utf-8")
    
    # Récupération des paramètres de la commande
    if len(sys.argv) < 4:
        log(u'Nombre de paramètres incorrect')
        sys.exit(1)
    
    largeur = sys.argv[1]
    output = sys.argv[2]
    json_file = sys.argv[3]
    
    json_data = open(json_file)
    data = json.load(json_data)
    
    # Création du fichier de licence
    file_name = os.path.dirname(os.path.realpath(__file__)) + "/" + output + "/LICENCE_commons.txt"
    licence_file = codecs.open(file_name, "w", "utf-8")
    
    result_download_images = download_images(largeur, output, data)
    
    log(u'======')
    log(str(result_download_images['images_requete']) + u' images requêtées')
    log(str(result_download_images['images_erreur']) + u' erreurs détectées sur les images')
    log(str(result_download_images['images_downloaded']) + u' images téléchargées')
    
    log_file.close()

