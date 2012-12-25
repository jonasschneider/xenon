THREE = require('three')
textureFlare0 = THREE.ImageUtils.loadTexture( "/images/textures/lensflare/lensflare0.png" )
textureFlare2 = THREE.ImageUtils.loadTexture( "/images/textures/lensflare/lensflare2.png" )
textureFlare3 = THREE.ImageUtils.loadTexture( "/images/textures/lensflare/lensflare3.png" )
    
module.exports = class BigAssLensFlare
  constructor: (light) ->
    flareColor = new THREE.Color(0xffffff)
    flareColor.copy light.color
    THREE.ColorUtils.adjustHSV flareColor, 0, -0.5, 0.5

    lensFlareUpdateCallback = (object) ->
      f = undefined
      fl = object.lensFlares.length
      flare = undefined
      vecX = -object.positionScreen.x * 2
      vecY = -object.positionScreen.y * 2
      f = 0
      while f < fl
        flare = object.lensFlares[f]
        flare.x = object.positionScreen.x + vecX * flare.distance
        flare.y = object.positionScreen.y + vecY * flare.distance
        flare.rotation = 0
        f++
      object.lensFlares[2].y += 0.025
      object.lensFlares[3].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180


    lensFlare = new THREE.LensFlare(textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor)
    lensFlare.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
    lensFlare.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
    lensFlare.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
    lensFlare.add textureFlare3, 60, 0.6, THREE.AdditiveBlending
    lensFlare.add textureFlare3, 70, 0.7, THREE.AdditiveBlending
    lensFlare.add textureFlare3, 120, 0.9, THREE.AdditiveBlending
    lensFlare.add textureFlare3, 70, 1.0, THREE.AdditiveBlending
    lensFlare.customUpdateCallback = lensFlareUpdateCallback
    lensFlare.position = light.position

    @el = lensFlare