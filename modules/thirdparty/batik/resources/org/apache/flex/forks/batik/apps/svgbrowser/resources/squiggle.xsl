<?xml version="1.0" standalone="no"?>
<!-- ====================================================================== 
     Copyright 2002,2004 The Apache Software Foundation
     
     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
     
         http://www.apache.org/licenses/LICENSE-2.0
     
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     
     See the License for the specific language governing permissions and
     limitations under the License.
     ====================================================================== -->

<!-- ========================================================================= -->
<!-- This simple XSL stylesheet is used to automatically generate the splash   -->
<!-- screen for the documentation and the Squiggle browser. See the 'splash'   -->
<!-- target in build.xml.                                                      -->
<!--                                                                           -->
<!-- @author vincent.hardy@eng.sun.com                                         -->
<!-- @version $Id: squiggle.xsl,v 1.3 2004/08/18 07:11:30 vhardy Exp $      -->
<!-- ========================================================================= -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
                              xmlns:xlink="http://www.w3.org/1999/xlink"
                              xmlns:xalan="http://xml.apache.org/xalan" 
                              exclude-result-prefixes="xalan">

        <xsl:param name="version" >currentVersion</xsl:param>
        <xsl:param name="revisionType" >beta</xsl:param>
        <xsl:param name="revisionNumber" >3</xsl:param>
	<xsl:output method="xml" indent="yes" media-type="image/svg"/> 

    <xsl:template match="/" >

<svg id="body" width="492" height="150" viewBox="0 0 492 150">
<title>Squiggle Startup screen</title>
    <defs>
        <g id="card">
          <rect height="150" width="492" y="0" x="0"/>
        </g>

        <radialGradient id="backgroundGradient" r=".7" cx="0.5">
            <stop offset="0" stop-color="white" />
            <stop offset=".5" stop-color="rgb(124, 65, 239)" />
            <stop offset="1" stop-color="black" />
        </radialGradient>

        <pattern id="stripes" patternUnits="userSpaceOnUse" x="0" y="0" width="50" height="4">
            <rect width="50" height="2" fill="black" fill-opacity=".2" />
        </pattern>

        <filter id="dropShadow" primitiveUnits="objectBoundingBox" x="-.2" y="-.2" width="1.4" height="1.4">
            <feGaussianBlur in="SourceAlpha" stdDeviation="2" x="-.2" y="-.2" width="1.4" height="1.4"/> 
            <feOffset dx="3" dy="3" />
            <feComponentTransfer result="shadow">
               <feFuncA type="linear" slope="1" intercept="0" />
            </feComponentTransfer>
            <feMerge>
                <feMergeNode />
                <feMergeNode in="SourceGraphic" />
            </feMerge>
        </filter>

        <symbol id="Batik_Squiggle" stroke="none" viewBox="0 0 540 570">
          <path id="Batik_Squiggle_Blue" fill="#6666FF"
            d="M172,44C137,60,31,135,11,199c-8,27,22,48,44,33
               C14,306-1,332,0,356c0,14,13,42,44,27c8-4,35-25,52-41
               c14-1,24-11,42-28c17,14,36,10,52-7c22,2,82-78,44-108
               c-3-24-30-37-53-18c-6-2-13-1-18,1c22-35,43-82,49-105
               C219,47,188,36,172,44z"/>
          <path id="Batik_Squiggle_Red" fill="#FF0000"
            d="M400,0c-18,3-49,31-49,31c-29,23-43,58-28,95
               c-13,14-29,44-29,67c0,28,20,52,50,29c7,8,21,16,37,5
               c-5,29,3,48,26,49c1,10,13,31,36,17c16-10,58-39,79-56
               c25-23,25-94-18-89c33-59-3-96-27-84c-10,4-46,25-52,30
               c-1-7-5-12-11-14C436,45,436-5,401,0z"/>
          <path id="Batik_Squiggle_Green" fill="#33CC33"
            d="M275,353c-46,12-88,43-114,91c-9,16,6,37,25,33
               c-14,24-40,67-15,81c28,16,52-8,60-15c18,21,50,10,81-17
               c41,14,68-2,103-53c8-12,30-43,30-65c0-16-15-30-35-21
               c-1-12-9-38-53-19c-10-6-31-5-54,17
               C308,375,300,347,275,353z"/>
        </symbol>
    </defs>

    <g id="content" filter2="url(#dropShadow)">
      <g id="top">
        <use xlink:href="#card" fill="url(#backgroundGradient)" />
        <use xlink:href="#card" fill="url(#stripes)" />
        
        <use filter="url(#dropShadow)" xlink:href="#Batik_Squiggle"
          y="11" x="46" width="114" height="131"/>

        <g id="topText" font-family="'20th Century Font', 'Futura XBlk BT'"
          text-anchor="middle" fill="white" filter="url(#dropShadow)">
          <text x="246" y="85"><tspan font-size="95"
           >squiggle</tspan></text>
          <text font-size="17" x="246" y="115"><tspan
          >Built with the Batik SVG toolkit</tspan
          ><tspan dy="1em" x="246">http://xml.apache.org/batik</tspan></text>
          <text x="487" y="140" text-anchor="end" font-size="16" 
            fill="red"><xsl:value-of select="$version" />
          <xsl:if test="$revisionType != 'revisionType'">
            <xsl:value-of 
              select="substring-after($revisionType, 'revisionType')" />
            <xsl:text> </xsl:text><xsl:value-of 
            select="substring-after($revisionNumber, 'revisionNumber')"/>
          </xsl:if>
        </text>
      </g>
    </g>
  </g>

  <font horiz-adv-x="419" ><font-face
  font-family="20th Century Font"
  units-per-em="1000"
  panose-1="0 0 4 0 0 0 0 0 0 0"
  ascent="830"
  descent="-201"
  alphabetic="0" />
  <missing-glyph horiz-adv-x="500" 
    d="M63 0V800H438V0H63ZM125 63H375V738H125V63Z" />
  <glyph unicode=" " glyph-name="space" horiz-adv-x="260" />
  <glyph unicode="-" glyph-name="hyphen" horiz-adv-x="331" 
    d="M294 325Q294 302 280 287Q264 269 238 269H105Q78 269 63 287Q49 302 49 325Q49 348 63 364T105 381H238Q264 381 279 365T294 325Z" />
  <glyph unicode="." glyph-name="period" horiz-adv-x="225" 
    d="M190 55Q190 30 173 13T130 -5Q105 -5 88 12T70 55Q70 80 87 97T130 115Q155 115 172 98T190 55Z" />
  <glyph unicode="/" glyph-name="slash" horiz-adv-x="363" 
    d="M359 579Q359 568 355 557L134 -3Q120 -39 84 -39Q61 -39 43 -24T25 15Q25 26 30 38L251 598Q265 634 301 634Q324 634 341 619T359 579Z" />
  <glyph unicode="0" glyph-name="zero" horiz-adv-x="539" 
    d="M508 290Q508 150 462 77Q405 -11 274 -11Q40 -11 40 290Q40 590 274 590Q508 590 508 290ZM396 290Q396 383 379 421Q352 479 274 479Q195 479 169 421Q152 383 152 290Q152 196 169 158Q195 101 274 101Q353 101 379 158Q396 195 396 290Z" />
  <glyph unicode="1" glyph-name="one" horiz-adv-x="300" 
    d="M261 55Q261 28 244 14T205 -1Q182 -1 166 13T149 55V433Q133 423 116 423Q92 423 74 441T55 483Q55 517 94 537L160 571Q183 583 204 583Q229 583 245 569T261 537V55Z" />
  <glyph unicode="2" glyph-name="two" horiz-adv-x="479" 
    d="M457 54Q457 32 442 16T399 -1H33V73Q33 184 111 255Q153 294 257 343Q335 379 335 405Q335 457 286 470Q271 474 251 474Q210 474 166 458Q156 454 145 454Q122 454 107 472T91 512Q91 550 129 563Q189 585 249 585Q338 585 391 539Q447 490 447 399Q447 331 370 283Q299 246 228 210Q151 167 151 111H399Q426 111 443 93Q457 77 457 54Z" />
  <glyph unicode="3" glyph-name="three" horiz-adv-x="508" 
    d="M484 188Q484 95 418 43Q357 -4 261 -4Q153 -4 90 56Q72 73 72 96Q72 118 89 135T129 153Q151 153 168 137Q198 108 261 108Q373 108 373 188Q373 256 283 256Q274 256 267 256Q214 273 214 312Q214 339 250 366Q333 397 333 427Q333 451 308 466Q287 478 260 478Q223 478 199 449Q182 428 157 428Q135 428 117 445T99 485Q99 505 114 521Q171 590 260 590Q334 590 388 546Q445 499 445 427Q445 353 396 330Q439 320 464 270Q484 230 484 188Z" />
  <glyph unicode="4" glyph-name="four" horiz-adv-x="555" 
    d="M522 180Q522 158 507 142T466 125H450V53Q450 27 433 12T394 -3Q371 -3 355 12T338 53V125H30L450 581V236H466Q492 236 507 220T522 180ZM338 236V306L276 236H338Z" />
  <glyph unicode="5" glyph-name="five" horiz-adv-x="514" 
    d="M487 228Q487 93 393 31Q329 -11 245 -11Q153 -11 81 19Q46 34 46 69Q46 92 62 110T101 128Q113 128 125 122Q176 101 245 101Q294 101 330 129Q375 163 375 225Q375 303 267 303H57Q69 394 69 442Q69 514 74 581H400Q426 581 441 565T456 525Q456 502 441 486T400 469H178Q176 448 172 415H269Q371 415 427 370Q487 322 487 228Z" />
  <glyph unicode="6" glyph-name="six" horiz-adv-x="498" 
    d="M474 203Q474 103 410 47Q350 -7 247 -7Q144 -7 86 62Q33 126 33 230Q33 355 107 462Q191 582 311 582Q336 582 351 565T366 525Q366 476 316 471Q247 462 200 401H276Q363 401 418 346T474 203ZM362 203Q362 289 276 289H149Q145 266 145 230Q145 176 172 141T247 105Q295 105 325 126Q362 152 362 203Z" />
  <glyph unicode="7" glyph-name="seven" horiz-adv-x="498" 
    d="M491 581Q388 486 315 318Q248 163 248 52Q248 -1 196 -1Q172 -1 154 14T136 58Q136 134 175 259Q219 403 277 469H81Q55 469 40 485T25 525Q25 548 39 564T81 581H491Z" />
  <glyph unicode="8" glyph-name="eight" horiz-adv-x="508" 
    d="M484 188Q484 95 418 43Q357 -4 261 -4Q166 -4 105 44Q37 96 37 188Q37 229 56 268T108 327Q79 353 79 428Q79 496 136 544Q190 590 260 590Q330 590 386 544Q445 495 445 427Q445 358 417 330Q447 316 467 268Q484 226 484 188ZM333 427Q333 450 312 462T263 475Q234 475 214 463Q191 450 191 428Q191 393 214 373Q234 354 263 355Q291 355 312 374T333 427ZM373 188Q373 224 332 243Q301 257 261 257Q215 257 184 240Q149 221 149 188Q149 149 185 126Q217 105 263 105Q308 106 338 126Q373 149 373 188Z" />
  <glyph unicode="9" glyph-name="nine" horiz-adv-x="491" 
    d="M465 348Q465 224 390 116Q307 -4 187 -4Q161 -4 147 13T132 53Q132 102 182 108Q251 116 298 177H222Q134 177 79 232T24 375Q24 476 86 531T251 586Q354 586 411 517Q465 452 465 348ZM353 348Q353 402 326 438T251 474Q203 474 172 452Q136 427 136 375Q136 289 222 289H348Q353 313 353 348Z" />
  <glyph unicode=":" glyph-name="colon" horiz-adv-x="220" 
    d="M190 335Q190 310 173 293T130 275Q105 275 88 292T70 335Q70 360 87 377T130 395Q155 395 172 378T190 335ZM190 55Q190 30 173 13T130 -5Q105 -5 88 12T70 55Q70 80 87 97T130 115Q155 115 172 98T190 55Z" />
  <glyph unicode="B" glyph-name="B" horiz-adv-x="549" 
    d="M526 188Q526 93 464 44Q406 -1 306 -1H43V581H298Q367 581 419 538Q476 490 476 415Q476 363 445 323Q526 274 526 188ZM365 415Q365 437 347 453T298 469H155V353H298Q323 353 344 371T365 415ZM415 188Q415 205 395 222Q364 248 298 248H155V111H305Q358 111 383 124Q415 142 415 188Z" />
  <glyph unicode="G" glyph-name="G" horiz-adv-x="612" 
    d="M597 230Q597 132 514 63T322 -7Q195 -7 111 78T27 290Q27 427 106 511T322 595Q458 595 541 504Q557 487 557 467Q557 444 540 427T499 410Q476 410 459 429Q409 483 322 483Q232 483 186 432T139 290Q139 209 190 157T322 105Q380 105 425 135Q465 162 479 201H354Q328 201 313 217T298 257Q298 280 313 296T354 313H597V230Z" />
  <glyph unicode="S" glyph-name="S" horiz-adv-x="519" 
    d="M506 186Q506 127 464 76T365 6Q322 -7 267 -7Q175 -7 87 28Q52 42 52 78Q52 101 67 118T106 136Q117 136 129 132Q196 105 267 105Q307 105 334 114Q356 121 371 139T387 176Q387 193 374 207Q345 242 259 254Q44 284 44 424Q44 509 125 552Q190 585 283 585Q376 585 436 556Q468 540 468 507Q468 485 453 467T414 449Q401 449 387 455Q351 473 281 473V473Q156 473 156 424Q156 390 255 366Q321 351 387 336Q437 317 466 286Q506 242 506 186Z" />
  <glyph unicode="V" glyph-name="V" horiz-adv-x="571" 
    d="M556 540Q556 530 553 520L391 58Q369 -6 291 -6Q213 -6 191 58L32 520Q28 530 28 540Q28 564 46 579T86 595Q124 595 137 557L242 260Q278 158 292 93Q314 178 342 257L447 557Q460 595 498 595Q521 595 538 580T556 540Z" />
  <glyph unicode="_" glyph-name="underscore" horiz-adv-x="616" 
    d="M616 -59Q616 -82 602 -97Q587 -115 560 -115H101Q75 -115 60 -97Q46 -82 46 -59Q46 -36 60 -20T101 -3H560Q587 -3 601 -19T616 -59Z" />
  <glyph unicode="a" glyph-name="a" horiz-adv-x="500" 
    d="M464 -2H212Q134 -2 88 41T41 164Q41 250 102 294Q154 333 240 333Q267 333 301 316Q340 297 352 269Q354 277 354 288Q354 348 293 363Q288 364 250 367Q225 370 210 380Q188 396 187 427Q187 479 259 479Q345 479 401 437Q464 390 464 307V-2ZM352 110V154Q352 189 312 209Q279 226 240 226Q153 226 153 164Q153 110 226 110H227H352Z" />
  <glyph unicode="b" glyph-name="b" horiz-adv-x="456" 
    d="M437 221Q437 123 379 62Q320 -2 223 -2Q197 -2 171 6T138 35Q130 0 93 0Q71 0 55 14T38 56V509Q38 536 54 550T94 565Q116 565 132 550T149 509V423Q166 467 232 467Q317 467 374 400Q437 324 437 221ZM326 218Q326 283 288 327Q267 353 219 353Q149 353 149 295V180Q149 148 182 127Q206 110 223 110Q272 110 299 139T326 218Z" />
  <glyph unicode="c" glyph-name="c" horiz-adv-x="432" 
    d="M430 76Q430 49 405 31Q347 -9 267 -9Q160 -9 97 56T33 230Q33 331 99 400T267 469Q333 469 388 437Q417 420 417 390Q417 368 401 350T361 332Q346 332 332 340Q303 357 267 357Q213 357 179 322T145 230Q145 103 267 103Q312 103 342 124Q357 135 374 135Q397 135 413 117T430 76Z" />
  <glyph unicode="e" glyph-name="e" horiz-adv-x="512" 
    d="M491 155H165Q195 104 271 104Q299 104 317 85Q332 69 332 46Q332 23 317 8T271 -8Q166 -8 101 56T36 228Q36 341 99 407T273 473Q379 473 438 394Q491 323 491 213V155ZM373 267Q364 309 345 331Q319 361 273 361Q168 361 151 267H152H373Z" />
  <glyph unicode="g" glyph-name="g" horiz-adv-x="479" 
    d="M439 111Q439 10 390 -72Q333 -170 238 -170Q213 -170 198 -153T183 -113Q183 -67 230 -59Q257 -54 277 -37Q291 -24 298 -16Q309 -1 312 15Q287 1 253 1Q39 1 39 240Q39 333 100 396T255 460H327Q366 460 402 432T439 367V111ZM327 141V314Q327 330 300 340Q279 349 255 349Q209 349 180 318T151 240Q151 173 169 146Q192 113 253 113Q299 113 327 141Z" />
  <glyph unicode="h" glyph-name="h" horiz-adv-x="464" 
    d="M431 284V55Q431 28 414 14T375 -1Q352 -1 336 13T319 55V284Q319 313 298 328T247 344Q214 344 189 327T163 281V55Q163 28 146 14T107 -1Q84 -1 68 13T51 55V525Q51 552 67 566T107 581Q129 581 146 567T163 525V407Q192 455 249 455Q323 455 374 412Q431 364 431 284Z" />
  <glyph unicode="i" glyph-name="i" horiz-adv-x="201" 
    d="M164 551Q164 527 148 511T108 494Q85 494 69 510T52 551Q52 574 68 590T108 607Q131 607 147 591T164 551ZM164 55Q164 28 148 14T108 -1Q85 -1 70 13Q52 28 52 55V404Q52 431 70 446Q85 460 108 460Q131 460 147 446T164 404V55Z" />
  <glyph unicode="k" glyph-name="k" horiz-adv-x="470" 
    d="M456 54Q456 31 438 15T397 -2Q368 -2 351 25L224 233Q200 208 148 160V55Q148 28 131 14T92 -1Q69 -1 53 13T36 55V527Q36 553 52 568T92 583Q114 583 131 568T148 527V299Q166 332 194 360L263 429Q281 446 302 446Q325 446 342 429T360 388Q360 366 342 349Q315 323 308 311L447 84Q456 69 456 54Z" />
  <glyph unicode="l" glyph-name="l" horiz-adv-x="200" 
    d="M164 55Q164 28 148 14T108 -1Q85 -1 70 13Q52 28 52 55V526Q52 552 70 568Q85 582 108 582Q131 582 147 567T164 526V55Z" />
  <glyph unicode="m" glyph-name="m" horiz-adv-x="836" 
    d="M800 55Q800 28 784 14T744 -1Q722 -1 705 13T688 55V294Q688 355 625 355H486V55Q486 28 469 14T430 -1Q407 -1 391 13T374 55V294Q374 355 310 355H171V55Q171 28 155 14T115 -1Q92 -1 77 13Q59 28 59 55V468H625Q702 468 751 420T800 294V55Z" />
  <glyph unicode="o" glyph-name="o" horiz-adv-x="528" 
    d="M498 230Q498 125 434 58T264 -9Q155 -9 92 59Q31 124 31 230Q31 331 96 400T264 469Q367 469 432 401T498 230ZM386 230Q386 287 353 322T264 357Q211 357 177 322T143 230Q143 103 264 103Q323 103 354 137T386 230Z" />
  <glyph unicode="p" glyph-name="p" horiz-adv-x="457" 
    d="M436 244Q436 144 383 75Q326 -1 229 -1Q209 -1 187 9Q159 20 150 40V-98Q150 -124 134 -139T94 -154Q71 -154 56 -140Q38 -124 38 -98V413Q38 439 56 455Q71 469 94 469Q128 469 137 430Q167 468 218 468Q314 468 375 404T436 244ZM324 244Q324 306 289 334Q262 356 218 356Q150 356 150 290V175Q150 111 229 111Q285 111 308 160Q324 193 324 244Z" />
  <glyph unicode="q" glyph-name="q" horiz-adv-x="490" 
    d="M446 -98Q446 -124 430 -139T390 -154Q367 -154 351 -139T334 -98V40Q305 -1 255 -1Q166 -1 109 65Q48 133 48 244Q48 340 109 404T266 468Q306 468 347 430Q352 446 366 457T395 469Q417 469 431 452T446 413V-98ZM334 180V290Q334 356 266 356Q217 356 189 325T160 244Q160 191 181 155Q206 111 255 111Q282 111 306 130Q334 151 334 180Z" />
  <glyph unicode="r" glyph-name="r" horiz-adv-x="374" 
    d="M364 413Q364 390 352 375Q338 357 315 357Q310 357 300 358T285 360Q239 360 202 331Q163 299 163 254V55Q163 28 147 14T107 -1Q84 -1 69 13Q51 28 51 55V406Q51 430 68 446T109 462Q131 462 146 443T162 389V389Q162 388 162 387Q179 441 232 460Q265 472 292 472Q306 472 319 469Q364 458 364 413Z" />
  <glyph unicode="s" glyph-name="s" horiz-adv-x="473" 
    d="M445 153Q445 67 375 26Q319 -6 227 -6Q173 -6 98 21Q60 35 60 72Q60 95 75 112T114 130Q125 130 136 126Q193 106 227 106Q288 106 316 125Q332 136 332 147Q332 168 265 180T193 193Q150 202 125 213Q51 247 51 320Q51 398 121 441Q180 478 263 478Q333 478 387 453Q421 438 421 404Q421 381 405 363T366 345Q354 345 341 351Q309 366 263 366Q261 366 254 366T241 366Q205 366 185 357T165 334Q165 319 186 311Q204 304 277 289Q347 275 375 263Q445 233 445 153Z"/>
  <glyph unicode="t" glyph-name="t" horiz-adv-x="350" 
    d="M339 52Q339 -8 233 -8Q90 -8 90 148V350Q66 350 53 366T40 405Q40 417 65 433T90 462V507Q90 533 106 548T146 563Q168 563 185 548T202 507V462H281Q308 462 322 446T337 406Q337 383 323 367T281 350H202V137Q202 117 207 111T233 104Q241 104 257 106T282 109Q305 109 322 92T339 52Z" />
  <glyph unicode="u" glyph-name="u" horiz-adv-x="517" 
    d="M474 0H223Q145 0 96 47T47 173V412Q47 438 64 453T103 468Q126 468 142 453T159 412V173Q159 112 223 112H362V412Q362 438 380 454Q395 468 418 468Q441 468 457 453T474 412V0Z" />
  <glyph unicode="w" glyph-name="w" horiz-adv-x="802" 
    d="M777 408Q777 398 773 387L668 93Q631 -9 553 -9Q517 -9 487 17T442 93Q431 129 400 255Q381 184 379 175T351 93Q316 -8 237 -9Q201 -9 172 17Q140 44 125 93L33 388Q30 398 30 407Q30 431 47 447T88 463Q126 463 139 424L200 239Q207 220 243 92Q253 132 288 244L347 415Q364 465 403 465Q442 465 460 412L519 234Q528 210 560 92Q568 125 601 231L668 425Q681 462 718 462Q741 462 759 447T777 408Z" />
  <glyph unicode="x" glyph-name="x" horiz-adv-x="432" 
    d="M402 54Q402 32 384 15T342 -2Q314 -2 298 23L222 142L146 23Q130 -2 103 -2Q80 -2 61 15T42 54Q42 71 54 87L164 230L54 374Q42 389 42 406Q42 429 61 446T103 463Q130 463 146 438L222 318L298 438Q314 463 342 463Q365 463 383 446T402 406Q402 389 390 374L280 230L390 87Q402 71 402 54Z" />
  <hkern g1="V" g2="c" k="57" />
  <hkern g1="V" g2="e" k="57" />
  <hkern g1="V" g2="o" k="57" />
  <hkern g1="V" g2="r" k="47" />
  <hkern g1="V" g2="u" k="47" />
  <hkern g1="e" g2="t" k="19" />
  <hkern g1="f" g2="a" k="94" />
  <hkern g1="f" g2="c" k="94" />
  <hkern g1="f" g2="e" k="94" />
  <hkern g1="f" g2="o" k="94" />
  <hkern g1="r" g2="a" k="85" />
  <hkern g1="r" g2="c" k="19" />
  <hkern g1="r" g2="e" k="19" />
  <hkern g1="r" g2="g" k="47" />
  <hkern g1="r" g2="o" k="28" />
  <hkern g1="w" g2="a" k="38" />
  <hkern g1="w" g2="c" k="38" />
  <hkern g1="w" g2="e" k="38" />
  <hkern g1="w" g2="g" k="38" />
  <hkern g1="w" g2="o" k="38" />
</font>
</svg>

    </xsl:template>
</xsl:stylesheet>
