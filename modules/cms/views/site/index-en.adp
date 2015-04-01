<% 
#ns_adp_include -tcl -nocache  ../../tcl/init.tcl   
#set c [Controller new]
#$c urlAction
#$c lang
dict set pageinfo title  "United Brain Power - The Community that enriches your productivity"
dict set pageinfo  keywords "United Brain Power, Every Second Matters, Goldbag"
set bhtml [bhtml new]

$bhtml addPlugin mycover { 
	css "/css/ubp.css"
		css-min "/css/ubp.css"
}

$bhtml lazyloader

dict set pageinfo header {
	<style>
	.intro-message > h2 {
		font-size:3em;
	}
	</style>
    <!-- Header -->
    <div class="intro-header">

        <div class="container">

            <div class="row">
                <div class="col-lg-12">
                    <div class="intro-message">

				<img title="United Brain Power"  alt="United Brain Power" src="/img/logo.png" class="logo lazy">
                        <h1>The community that enriches your productivity. </h1> 
						<h2> Simple solutions for everyday tasks.</h2>
                        <hr class="intro-divider">
                        
                         <a href="}
						dict append pageinfo header [my getUrl -controller user register] 
					dict append pageinfo header {" class="btn btn-success btn-lg "><i class="fa fa-cogs fa-fw"></i>
						Efficiency made simple?  <span style="font-weight:800">I want it!</span></a>
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
                <div class="col-lg-5 col-sm-6">
                    <hr class="section-heading-spacer">
                    <div class="clearfix"></div>
                    <h2 class="section-heading">Effective software for a more efficient life</h2>
                    <p class="lead">Manage your time correctly with <a>Every Second Matters</a> time-management project.<br>
					How about some financial help? Then you might consider using our <a>Personal GoldBag</a> app.<br>
					Want some help learning? Then you certainly would want to look into our <a>Brain Organizer</a>.
					</p>
					<p>
}
append page [$bhtml a -class "btn-lg btn center-block" -type primary -fa fa-rocket "Tour of United Brain Power" [my getUrl  projects-tour] ]
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
                <div class="col-lg-5 col-lg-offset-1 col-sm-push-6  col-sm-6">
                    <hr class="section-heading-spacer">
                    <div class="clearfix"></div>
                    <h2 class="section-heading">Advanced Programming Solutions and task automation</h2>
                    <p class="lead">Take your firm to the 21th century by automating daunting tasks.
					We'll analyse any repetitive task your employees do and help them acheive more by creating the perfect tools to help you on the way.
					</p>
					<p>
}
append page [$bhtml a -class "btn-lg btn center-block" -type success -fa fa-road "See our projects and hire us" [my getUrl hire-us  ]]
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
                <div class="col-lg-5 col-sm-6">
                    <hr class="section-heading-spacer">
                    <div class="clearfix"></div>
                    <h2 class="section-heading">Marvelous teaching platform <br>Education at it's finest</h2>
                    <p class="lead">Education should lead to mastery of any skill not just to knowledge.
					We've currently creating a comprehensive terrific book concerning many things we need in real life but never learn in school.
					<br>Also, programming and IT courses for youngsters available.
					</p>
					<p>
}
append page [$bhtml a -class "btn-lg btn center-block" -type warning -fa fa-university "Learn from us" [my getUrl learn] ]
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
                    <h2>Free access to all our knowledge without needing to register on our blog:</h2>
                </div>
                <div class="col-lg-6">
}
append page [$bhtml a -class "btn-lg btn" -type success -fa fa-book "Read everything from our blog!" [my getUrl -controller blog index] ]
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

#ubp.adp
#ns_puts $page
#ns_adp_include -cache 1 ../layout.adp -bhtml $bhtml -title $title -keywords  $keywords -header $header -nocontent 1 $page  
%>

