<% 
#ns_adp_include -tcl -nocache  ../../tcl/init.tcl   
#set c [Controller new]
#$c urlAction
#$c lang
dict set pageinfo title   "United Brain Power - Comunitatea care-ți îmbogățește productivitatea"
dict set pageinfo  keywords "United Brain Power, Every Second Matters, Goldbag"
set bhtml [bhtml new]

$bhtml addPlugin mycover { 
	css "/css/ubp.css"
		css-min "/css/ubp.css"
}
$bhtml addPlugin animate { 
	css "/css/animate.css"
		css-min "/css/animate.min.css"
}
$bhtml addPlugin wow { 
	js "/js/wow.js"
	js-min "/js/wow.min.js"
}
$bhtml js {  new WOW().init(); }
$bhtml lazyloader

dict set pageinfo header {
	<style>
	.intro-message > h2 {
		font-size:3em;
	}
	.intro-message > h1 {
		font-size:5em;
	}
	</style>
    <!-- Header -->
    <div class="intro-header">

        <div class="container">

            <div class="row">
                <div class="col-lg-12">
                    <div class="intro-message">

				<img title="United Brain Power"  alt="United Brain Power" src="/img/logo.png" class=" lazy logo">
                        <h1>Comunitatea care-ți îmbogățește productivitatea. </h1> 
						<h2> Soluții simple pentru sarcinile de zi cu zi.</h2>
                        <hr class="intro-divider">
                        
                         <a href="}
						dict append pageinfo header [my getUrl -controller user register] 
					dict append pageinfo header {" class="btn btn-success btn-lg "><i class="fa fa-cogs fa-fw"></i>
					 Eficiență reală? <span style="font-weight:800">Vreau și eu!</span></a>
                    </div>
                </div>
            </div>

        </div>
        <!-- /.container -->

    </div>
    <!-- /.intro-header -->
}

append page {
<style>
.content-section-b {
	background: url("/img/image_bg_2.jpg") no-repeat fixed center center / cover rgba(0, 0, 0, 0);
}
.content-section-b h2 { color: white; } 
.content-section-b p { color: white; } 
  </style>
  <!-- Page Content -->

    <div class="content-section-a">

        <div class="container">

            <div class="row">
                <div class="col-lg-5 col-sm-6 wow bounceInRight">
                    <hr class="section-heading-spacer">
                    <div class="clearfix"></div>
                    <h2 class="section-heading">Software eficace pentru o viata eficienta</h2>
                    <p class="lead">Stăpânește-ți timpul corect cu proiectul nostru de administrarea timpului <a>Every Second Matters</a>.<br>
				Ai nevoie de niste ajutor financiar? Ce zici daca inveti sa utilizezi  <a>Personal GoldBag</a> si nu te mai lasi prada imprumuturilor.<br>
					Ai nevoie de niște ajutor să înveți? Atunci cu siguranță ai vrea sa te încerci <a>Brain Organizer</a>.
					</p>
					<p>
}
append page [$bhtml a -class "btn-lg btn center-block" -type primary -fa fa-rocket "Turul United Brain Power" [my getUrl  tur-proiecte] ]
append page {
					</p>
                </div>
                <div class="col-lg-5 col-lg-offset-2 col-sm-6">
              <img class="img-responsive img-thumbnail lazy" data-src="/img/cool/efficient-life-effective-software.jpg"
					title="Efficient life using our effective software"	alt="Efficient life using our effective software">
					<noscript> 
					<img class="img-responsive img-thumbnail lazy" src="/img/cool/efficient-life-effective-software.jpg"
					title="Efficient life using our effective software"	alt="Efficient life using our effective software">
					</noscript>
                </div>
            </div>

        </div>
        <!-- /.container -->

    </div>
    <!-- /.content-section-a -->

    <div class="content-section-b">

        <div class="container">

            <div class="row">
                <div class="col-lg-5 col-lg-offset-1 col-sm-push-6  col-sm-6 wow bounceInLeft" data-wow-offset="250">
                    <hr class="section-heading-spacer">
                    <div class="clearfix"></div>
                    <h2 class="section-heading">Solutii avansate de programare si automatizare a sarcinilor</h2>
                    <p class="lead">
					Aduceti-va firma in secolul 21 prin automatizarea sarcinilor repetitive.
					Noi vom analiza orice sarcina repetitiva pe care angajatii dvs o fac si ii vom ajuta
					sa obtina mai mult prin creerea uneltelor perfecte pentru fiecare loc de munca.
					</p>
					<p>
}
append page [$bhtml a -class "btn-lg btn center-block" -type success -fa fa-road "Vezi proiectele noastre si angajeaza-ne" [my getUrl angajeaza-ne  ]]
append page {
					</p>

                </div>
                <div class="col-lg-5 col-sm-pull-6  col-sm-6">
				<img class="img-responsive img-thumbnail lazy" data-src="/img/cool/task-automation.jpg"
					alt="Task automation and advanced programming solutions"
					title="Task automation and advanced programming solutions" >
					<noscript> 
					<img class="img-responsive img-thumbnail lazy"  src="/img/cool/task-automation.jpg"
					alt="Task automation and advanced programming solutions"
					title="Task automation and advanced programming solutions" >
					</noscript>                

                </div>
			</div>

        </div>
        <!-- /.container -->

    </div>
    <!-- /.content-section-b -->

    <div class="content-section-a">

        <div class="container">

            <div class="row">
                <div class="col-lg-5 col-sm-6 wow bounceInUp" data-wow-offset="250">
                    <hr class="section-heading-spacer">
                    <div class="clearfix"></div>
                    <h2 class="section-heading">Platforma de predare minunata <br>Cea mai selecta educatie</h2>
                    <p class="lead">Educatia ar trebui sa duca la iscusinta oricarui mestesug nu doar acumularea de informatie.
					Lucram in prezent la o carte cuprinzatoare de cele mai multe lucruri de care avem nevoie in viata reala pentru a putea 
					lucra eficient catre succes. Lucruri pe care nu le invata nimeni la scoala.
				
					<br>Din Martie-Aprilie 2015 incep cursurile de cunoastere si perfectionare in domeniul IT
										</p>
					<p>
}
append page [$bhtml a -class "btn-lg btn center-block" -type warning -fa fa-university "Invata impreuna cu noi" [my getUrl invata-catre-desavirsire] ]
append page {
					</p>

                </div>
                <div class="col-lg-5 col-lg-offset-2 col-sm-6">
                    <img class="img-responsive img-thumbnail lazy"  data-src="/img/cool/studying-happy.jpg"
					alt="Eduction and happy studying"
					title="Eduction and happy studying" >
					<noscript> 
					<img class="img-responsive img-thumbnail lazy"  src="/img/cool/studying-happy.jpg"
					alt="Eduction and happy studying"
					title="Eduction and happy studying" >
					</noscript>

                </div>
            </div>

        </div>
        <!-- /.container -->

    </div>
    <!-- /.content-section-a -->

    <div class="banner">

        <div class="container">

            <div class="row">
                <div class="col-lg-6">
                    <h2>Acces gratuit la toate cunostintele noastre:</h2>
                </div>
                <div class="col-lg-6">
}
append page [$bhtml a -class "btn-lg btn" -type success -fa fa-book "Citeste si cunoaste de pe blog" [my getUrl -controller blog index] ]
append page {               
<ul class="list-inline banner-social-buttons">
              
                    </ul>
                </div>
            </div>

        </div>
        <!-- /.container -->

    </div>
    <!-- /.banner -->
}
dict set pageinfo nocontent 1


set page [encoding convertfrom utf-8 $page]
set pageinfo [encoding convertfrom utf-8  $pageinfo ]

#ubp.adp
#ns_puts $page
#ns_adp_include -cache 1 ../layout.adp -bhtml $bhtml -title $title -keywords  $keywords -header $header -nocontent 1 $page  
%>

