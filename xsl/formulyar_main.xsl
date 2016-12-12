<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com">
	<!--


	-->
	<xsl:template name="Head2">
		<script src="{$start/@prefix}p/formulyar/js/jquery.min-1.9.0.js"/>
		<script>var source = "";</script>
		<!-- по какой-то причине, если не втавить этот тэг, то предыдущий открывающий тег скрипта не закроется //
		<script src="{$start/@prefix}system/a/js/xalio.js"/>-->
		<script>var source2 = "";</script>
	</xsl:template>
	<xsl:template name="TitleAndMisk">
		<title>
			<xsl:value-of select="$start/@avatar"/>: административный раздел</title>
	</xsl:template>
	<!--	


	-->
	<xsl:template name="startBody">
		<xsl:param name="currentQuest"/>
		<!--<xsl:call-template name="footer"/>-->
		<xsl:apply-templates select="." mode="start">
			<xsl:with-param name="currentQuest" select="$currentQuest"/>
		</xsl:apply-templates>
	</xsl:template>
	<!--

	-->
	<xsl:template match="port|terminal" mode="start">
		<xsl:param name="currentQuest"/>
		<xsl:variable name="currentFact">
			<xsl:choose>
				<xsl:when test="$currentQuest='n'">
					<xsl:value-of select="$fact"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currentQuest"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="currentDirector" select="m8:director( $currentFact )"/>
		<xsl:variable name="newQuestName">
			<xsl:choose>
				<xsl:when test="exsl:node-set($parent)/*[last()-1]">
					<xsl:value-of select="name( exsl:node-set($parent)/*[last()-1] )"/>
				</xsl:when>
				<xsl:otherwise>n</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="holder" select="m8:holder( $fact )"/>
		<!--currentQuest: <xsl:value-of select="$currentQuest"/>-->
		<div id="factZone">
			<xsl:attribute name="style"><xsl:text>margin: 1em; display: inline-block; padding: 1em;</xsl:text><xsl:choose><xsl:when test="$currentQuest='n'">width: 960px;  background: #ECFFDC</xsl:when><xsl:otherwise>width: 840px;  background: #FFECDC</xsl:otherwise></xsl:choose></xsl:attribute>
			<xsl:choose>
				<!--max-width: 950px; min-width: 600px; -->
				<xsl:when test=" $currentFact = 'n' ">
					<xsl:comment/>
					<!--					<br/>
					<br/>
					<br/>-->
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="m8:index( $fact )/role">
							<xsl:message terminate="no">Зеленая карта</xsl:message>
							<div>
								<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх - ^ ^ ^ ^ ^ </xsl:message>
								<table style="font-size: 1em;" width="100%">
									<tr>
										<td width="30%" valign="top">
											<!-- #####  хлебные крошки  ##### -->
											<xsl:for-each select="m8:ancestor-or-self($currentFact)/*[position()!=last()]">
												<xsl:if test="position()!=1">
													<xsl:text> / </xsl:text>
												</xsl:if>
												<xsl:variable name="preceding-sibling" select="name( preceding-sibling::*[1] )"/>
												<a style="{m8:color( name() )}" title="{m8:holder( name() )}">
													<xsl:attribute name="href"><xsl:choose><xsl:when test="$currentQuest='n'"><xsl:value-of select="m8:root( name(), $modifier )"/></xsl:when><xsl:otherwise><xsl:value-of select="m8:root( $fact, name() )"/></xsl:otherwise></xsl:choose></xsl:attribute>
													<xsl:apply-templates select="." mode="simpleName"/>
												</a>
											</xsl:for-each>
										</td>
										<td width="40%" align="center" style="color: #444" valign="top">
											<!-- #####  заголовок  ##### -->
											<div style="padding-bottom: .4em">
												<a style="font-size: 1.3em; {m8:color( $currentFact )}" title="{m8:holder( $currentFact )}">
													
														<xsl:if test="$currentQuest!='n'"><xsl:attribute name="href"><xsl:value-of select="m8:root($currentQuest)"/></xsl:attribute></xsl:if>
													
													<xsl:choose>
														<xsl:when test="m8:port( $currentFact )/i[not(r)]">
															<xsl:apply-templates select="m8:port( $currentFact )/i/*" mode="simpleName"/>
															<xsl:text>&#160;</xsl:text>
															<sup style="font-size: .5em; color: #777" title="{$currentFact}">
																<xsl:value-of select="substring-before( substring-after( $currentFact, '-' ), '-' )"/>
															</sup>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>нечто </xsl:text>
															<xsl:value-of select="$currentFact"/>
														</xsl:otherwise>
													</xsl:choose>
												</a>
												<xsl:if test="$currentQuest='n'">
													<xsl:text>&#160;&#160;</xsl:text>
													<a href="{m8:root( $currentFact, $currentFact )}" title="использовать в модификаторе" style="color: #a85">
														<xsl:value-of select="$symbol_up"/>
													</a>
													<!--<a href="{m8:root( 'n', $currentFact )}" title="использовать в модификаторе" style="color: #a85">
														<xsl:value-of select="$symbol_up"/>
													</a>-->
													<!--&#8595;-->
												</xsl:if>
											</div>
											<!--<xsl:if test="$parentName != $typeName">
												<xsl:text>  c типом </xsl:text>
												<a href="{m8:root( $typeName )}" style="{m8:color( $typeName)}" title="{m8:holder( $typeName )}">
													<b>
														<xsl:apply-templates select="exsl:node-set($parent)/*[last()]/*" mode="simpleName"/>
													</b>
												</a>
											</xsl:if>
											<xsl:if test="$modifier != 'n'">
												<span> в модификации </span>
												<a href="{m8:root( $modifier )}" style="{m8:color( $modifier )}" title="{m8:holder( $modifier )}">
													<b>
														<xsl:apply-templates select="$start/@modifier" mode="simpleName"/>
													</b>
												</a>
											</xsl:if>-->
										</td>
										<!-- n500 r i n n500 -->
										<td width="30%" align="right" valign="top">
											<xsl:choose>
												<xsl:when test="$currentQuest!='n'">
													<!--<xsl:text>&#160;</xsl:text>
													<a href="{m8:root( 'n', $fact )}" title="использовать в модификаторе факт" style="color: #a85">&#8595;</a>
													<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>-->
													<a href="{m8:root( $modifier, $fact )}" title="поменять местами модификатор и факт" style="color: #6a6">
														<xsl:value-of select="$symbol_replace"/>
													</a>
												</xsl:when>
												<xsl:when test="$holder = $user">
													<xsl:if test="m8:index( $director )/object/*[name()!=$fact]">
														<form action="{m8:root( $fact )}" id="editParamOfPort" style="margin: .5em; display: inline;">
															<select name="r" onchange="this.form.submit()" style="border-color: #ddd; max-width: 200px; background: #ECFFDC">
																<option/>
																<xsl:for-each select="m8:index( $director )/object/*[name()!=$fact]">
																	<xsl:sort select="m8:title( name() )"/>
																	<option value="{name()}">
																		<xsl:value-of select="concat( m8:status( name() ), ' ', m8:title( name() ) )"/>
																	</option>
																</xsl:for-each>
															</select>
														</form>
													</xsl:if>
													<xsl:if test="$currentDirector != 'n' ">
														<xsl:text>&#160;</xsl:text>
														<a href="{m8:root( $fact )}?r={$newQuestName}" title="перемещение в факт {m8:title( $newQuestName )} ({ $newQuestName })">
															<xsl:value-of select="$symbol_up"/>
														</a>
													</xsl:if>
													<xsl:text>&#160;</xsl:text>
													<xsl:choose>
														<xsl:when test="$leader = $director">
															<a href="{m8:root( $director )}?a0={m8:triple( $fact )}" title="удаление" onclick="return confirm('Удаление факта &#171;{m8:title($fact)}&#187;')">
																<xsl:text>␡</xsl:text>
															</a>
														</xsl:when>
														<xsl:otherwise>
															<a href="{m8:root( $fact, $director )}&amp;r={$director}" title="сделать тип таким же">
																<xsl:value-of select="$symbol_replace"/>
															</a>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<span>владелец - </span>
													<span style="{m8:fact_color( $holder )}">
														<xsl:value-of select="$holder"/>
													</span>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
								</table>
								<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх (END) - ^ ^ ^ ^ ^ </xsl:message>
								<div style="padding: 1em 0">
								<xsl:call-template name="quest_port">
									<xsl:with-param name="currentQuest" select="$currentQuest"/>
									<xsl:with-param name="currentFact" select="$currentFact"/>
								</xsl:call-template></div>
								<!--<br style="clear: both"/>-->
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Красная карта</xsl:message>
							<div style="margin: 2em; padding: 1em; background: #FED">
								<div style="float: right">
									<a href="{m8:root()}">X</a>
								</div>
								<br style="clear: both"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
					<!--</div>-->
				</xsl:otherwise>
			</xsl:choose>
			<!--(  or m8:index( $fact )/director/*[name()!='n'][m8:director( name() )!=$fact] )-->
			<!-- and $modifier = 'n'-->
			<xsl:if test="$currentFact != 'n'">
				<div id="siblingLinkZone">
					<!--<xsl:attribute name="style"><xsl:text>padding: .2em; background: </xsl:text><xsl:choose><xsl:when test="$currentQuest='n'" xml:lang="#E8FFD8">#FFFFEF</xsl:when><xsl:otherwise xml:lang="#FFE8D8">#FFFFEF</xsl:otherwise></xsl:choose></xsl:attribute>-->
					<!--<table width="100%" style="font-size: .9em;" cellspacing="0" cellpadding="0">-->
					<!--	<tr>-->
					<xsl:message>{  {  {  {  {  - Зона ссылок вбок -  }  }  }  }  } </xsl:message>
					<!--<td align="center">-->
					<xsl:variable name="siblings">
						<xsl:for-each select="m8:index( $currentDirector )/object/*">
							<xsl:sort select="m8:title( name() )"/>
							<xsl:copy/>
						</xsl:for-each>
					</xsl:variable>
					<div>
						<xsl:attribute name="style"><xsl:text>padding: .8em; background: </xsl:text><xsl:choose><xsl:when test="$currentQuest='n'" xml:lang="#E8FFD8">#FCFFEC</xsl:when><xsl:otherwise xml:lang="#FFE8D8">#FFFCEC</xsl:otherwise></xsl:choose></xsl:attribute>
						<table width="100%" cellpadding="2" cellspacing="0">
							<tr>
								<td align="right" width="47%">
									<xsl:if test="exsl:node-set($siblings)/*[name()=$currentFact]/preceding-sibling::*">
										<xsl:variable name="predName" select="name(exsl:node-set($siblings)/*[name()=$currentFact]/preceding-sibling::*[1])"/>
										<a style="font-size: .9em; {m8:color( $predName )}" title="{m8:holder( $predName )}">
											<xsl:attribute name="href"><xsl:choose><xsl:when test="$currentQuest='n'"><xsl:value-of select="m8:root( $predName, $modifier )"/></xsl:when><xsl:otherwise><xsl:value-of select="m8:root( $fact, $predName )"/></xsl:otherwise></xsl:choose></xsl:attribute>
											<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$currentFact]/preceding-sibling::*[1]" mode="simpleName"/>
										</a>
									</xsl:if>
								</td>
								<td align="center">
									<a href="{m8:file( $currentFact, 'index.xml' )}" style="font-size: .9em; color: black">&#8660;</a>
								</td>
								<!--⯌&#160;&#11012;&#160;  &#10070;-->
								<!-- &#9668;&#160;&#160;&#9658;-->
								<td width="47%" align="left">
									<xsl:if test="exsl:node-set($siblings)/*[name()=$currentFact]/following-sibling::*">
										<xsl:variable name="nextName" select="name(exsl:node-set($siblings)/*[name()=$currentFact]/following-sibling::*[1])"/>
										<a style="font-size: .9em; {m8:color( $nextName )}" title="{m8:holder( $nextName )}">
											<xsl:attribute name="href"><xsl:choose><xsl:when test="$currentQuest='n'"><xsl:value-of select="m8:root( $nextName, $modifier )"/></xsl:when><xsl:otherwise><xsl:value-of select="m8:root( $fact, $nextName )"/></xsl:otherwise></xsl:choose></xsl:attribute>
											<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$currentFact]/following-sibling::*[1]" mode="simpleName"/>
										</a>
									</xsl:if>
								</td>
							</tr>
						</table>
					</div>
					<!--</td>-->
					<xsl:message>{  {  {  {  {  - Зона ссылок вбок (END) -  }  }  }  }  } </xsl:message>
					<!--</tr>-->
				</div>
			</xsl:if>
			<div id="downLink" style="padding: 0em; background: white">
				<xsl:message> v v v v v - Зона ссылок вниз - v v v v v </xsl:message>
				<xsl:if test="m8:index( $currentFact )/object/*[m8:director( name() ) = $currentFact]">
					<xsl:message>= = = = = = = - Раздел экземпляров - = = = = = =</xsl:message>
					<!--<b>Экземпляры</b>-->
					<div style="padding: 1em">
						<xsl:for-each select="m8:index( $currentFact )/object/*[m8:director( name() ) = $currentFact]">
							<xsl:sort select="m8:title( name() )"/>
							<div style="font-size: 1.3em; padding: .2em">
								<a href="{ m8:root( name(), $modifier )}" style="{m8:color( name() )}" title="{m8:holder( name() )}">
									<xsl:attribute name="href"><xsl:choose><xsl:when test="$currentQuest='n'"><xsl:value-of select="m8:root( name(), $modifier )"/></xsl:when><xsl:otherwise><xsl:value-of select="m8:root( $fact, name() )"/></xsl:otherwise></xsl:choose></xsl:attribute>
									<xsl:value-of select="concat( m8:status( name() ), ' ', m8:title( name() ) )"/>
								</a>
								<!-- функционал копирования был подгототовлен 2016-11-15, но провалился на отладке
											<xsl:if test="m8:port( name() )/*[name()!='r']">
												<xsl:text> </xsl:text>
												<sup>
													<a href="{ m8:root( $fact ) }?a={ m8:path( name(), 'subject_r' )/*/@triple }" style="color: green" title="копировать">
														<xsl:attribute name="href"><xsl:value-of select="concat( m8:root( $fact ), '?a=' )"/><xsl:for-each select="m8:port( name() )/*[name()!='r']"><xsl:variable name="sentN" select="translate( position(), '123456789', 'bcdefghkl' )"/><xsl:value-of select="concat( '&amp;', $sentN, '2=', name(),   '&amp;', $sentN, '3=', name(*) )"/></xsl:for-each></xsl:attribute>
														<xsl:text>⸗</xsl:text>
													</a>
												</sup>
											</xsl:if>-->
								<xsl:choose>
									<xsl:when test="1200 > $time - m8:path( name(), 'subject_r' )/*/@time">
										<xsl:text> </xsl:text>
										<sup style="color: red">new</sup>
									</xsl:when>
									<xsl:when test="120 > $time - m8:role1( name() )/*/@time">
										<xsl:text> </xsl:text>
										<sup style="color: magenta">change</sup>
									</xsl:when>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="m8:index( name() )/object">
										<sup style="color: #999; font-size: 10px">
											<xsl:value-of select="concat( ' (', count( m8:index( name() )/object/* ), ')' )"/>
										</sup>
									</xsl:when>
									<xsl:when test="m8:holder( name() )=$user">
										<!-- and $fact != 'n'-->
										<xsl:text> </xsl:text>
										<sup>
											<a href="{ m8:root( $fact ) }?a0={ m8:path( name(), 'subject_r' )/*/@triple }" style="color: #bbb" onclick="return confirm('Удаление факта &#171;{m8:title( name() )}&#187;')" title="удалить">del</a>
										</sup>
									</xsl:when>
								</xsl:choose>
							</div>
						</xsl:for-each>
					</div>
					<xsl:message>= = = = = = = - Раздел экземпляров (END) - = = = = = =</xsl:message>
				</xsl:if>
				<xsl:if test="m8:index( $fact )/object/*[name()!='n' and m8:director( name() )!=$fact]">
					<b style="color: #555">Состав</b>
					<div style="padding: 1em">
						<xsl:for-each select="m8:index( $fact )/object/*[name()!='n'][m8:director( name() )!=$fact]">
							<xsl:sort select="m8:title( name() )"/>
							<div style="padding: .2em">
								<a href="{ m8:root( name(), $modifier ) }" style="{m8:color( name() )}" title="{m8:holder( name() )}">
									<xsl:apply-templates select="m8:port( name() )/r/*" mode="simpleName"/>
									<xsl:text> :: </xsl:text>
									<xsl:apply-templates select="." mode="simpleName"/>
								</a>
							</div>
						</xsl:for-each>
					</div>
				</xsl:if>
				<xsl:if test="( $currentQuest = 'n' or 1 ) and $currentFact !='n'">
					<!--<xsl:if test="$modifier='n'">-->
					<xsl:message>= = = = = = = - Раздел упоминаний - = = = = = =</xsl:message>
					<div style="color: #777;">
						<!-- padding: 2em;-->
						<xsl:if test="m8:quest( $currentFact )/*[name()!=$currentFact]">
							<div style="display: flex; padding: 1em">
								<div style="text-align: left; margin: 0 auto; ">
									<!-- width: 500px-->
									<div style="padding: .4em; text-align: center">
										<a href="{m8:file( $currentFact, 'quest.xml' )}" style="color: #777">
											<b>модификатор для</b>
										</a>
									</div>
									<xsl:for-each select="m8:quest( $currentFact )/*[name()!=$currentFact]">
										<xsl:sort select="m8:title( name(), 'd', $currentFact )" data-type="number"/>
										<div style="padding: .1em">
											<xsl:choose>
												<xsl:when test="m8:index( name() )/subject">
													<a href="{m8:root( name(), $modifier )}" style="{ m8:color( name() )};" title="{ m8:holder( name() ) }">
														<xsl:value-of select="m8:title( m8:chief( name() ) )"/>
														<!--<xsl:apply-templates select="m8:port( name() )/r/*" mode="simpleName"/>-->
														<xsl:text> :: </xsl:text>
														<xsl:if test="m8:port( name(), $currentFact )/d[not( r )]"> [<xsl:value-of select="m8:title( name(), 'd', $currentFact )"/>
															<xsl:if test="m8:port( name(), $currentFact )/i[not( r )]">-<xsl:value-of select="m8:title( name(), 'i', $currentFact )"/>
															</xsl:if>] </xsl:if>
														<!--<xsl:apply-templates select="." mode="simpleName"/>-->
														<xsl:value-of select="m8:title( name() )"/>
													</a>
													<xsl:text> </xsl:text>
													<a href="{m8:root( name(), $currentFact )}">
														<span style="color: #FFF9B9; background: #555">&#160;мод&#160;</span>
													</a>
												</xsl:when>
												<xsl:otherwise>
													<xsl:apply-templates select="." mode="simpleName"/>
												</xsl:otherwise>
											</xsl:choose>
										</div>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="m8:role1( $currentFact )/*[name()!='n']">
							<!-- and $modifier = 'n'-->
							<div style="display: flex; padding: 1em">
								<div style="text-align: left; margin: 0 auto;">
									<div style="padding: .4em; text-align: center">
										<a href="{m8:dir( $currentFact, 'role1.xml' )}" style="color: #777">
											<b>модификация из</b>
										</a>
									</div>
									<!--<div style="padding: .2em; text-align: left; margin: 0 auto; width: 500px">-->
									<xsl:for-each select="m8:role1( $currentFact )/*[name()!='n']">
										<xsl:sort select="m8:title( name() )"/>
										<div style="padding: .1em">
											<a href="{m8:root( name(), $currentQuest )}" style="{ m8:color( name() )}" title="{ m8:holder( name() ) }">
												<xsl:value-of select="m8:title( m8:chief( name() ) )"/>
												<xsl:text> :: </xsl:text>
												<!--<xsl:apply-templates select="m8:port( name() )/r/*" mode="simpleName"/> :: <xsl:apply-templates select="." mode="simpleName"/>-->
												<xsl:value-of select="m8:title( name() )"/>
												<xsl:if test="m8:port( $currentFact, name() )/d[not( r )]"> [<xsl:value-of select="m8:title( $currentFact, 'd', name() )"/>
													<xsl:if test="m8:port( $currentFact, name() )/i[not( r )]">-<xsl:value-of select="m8:title( $currentFact, 'i', name() )"/>
													</xsl:if>] </xsl:if>
											</a>
											<xsl:text> </xsl:text>
											<a href="{m8:root( $currentFact, name() )}">
												<span style="color: #FFF9B9; background: #555">&#160;мод&#160;</span>
											</a>
										</div>
									</xsl:for-each>
									<!--</div>-->
								</div>
							</div>
						</xsl:if>
					</div>
				</xsl:if>
				<xsl:if test="$currentQuest = 'n' and $currentFact !='n'">
					<div>
						<xsl:if test="m8:path( $fact, 'n', 'terminal' )/*[not(r)][name()!=$director]">
							<!-- and $modifier = 'n' -->
							<div style="padding: 1em">
								<b>
									<a href="{m8:file( $fact, 'n', 'terminal.xml' )}" style="color: gray">упоминания в значении</a>
								</b>
								<div style="padding: .2em">
									<xsl:for-each select="m8:path( $fact, 'n', 'terminal' )/*[not(r)][name()!=$director]">
										<xsl:sort select="m8:title( name() )"/>
										<div>
											<a href="{m8:root( name(), $modifier ) }" style="{ m8:color( name() )}" title="{ m8:holder( name() ) }">
												<!--<xsl:apply-templates select="m8:port( name() )/r/*" mode="simpleName"/> :: <xsl:apply-templates select="." mode="simpleName"/>-->
												<xsl:value-of select="concat( m8:title( m8:director( name() ) ), ' :: ', m8:title( name() ) )"/>
											</a>
										</div>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="m8:index( $fact )/role/role2">
							<!-- and $modifier = 'n' -->
							<div style="padding: 1em">
								<b>
									<a href="{m8:file( $fact, 'n', 'dock.xml' )}" style="color: gray">упоминания в параметре</a>
								</b>
								<div style="padding: .2em">
									<xsl:for-each select="m8:path( $fact, 'n', 'dock' )/*">
										<xsl:sort select="m8:title( name() )"/>
										<div>
											<a href="{m8:root( name(), $modifier ) }" style="{ m8:color( name() )}" title="{ m8:holder( name() ) }">
												<xsl:value-of select="concat( m8:title( m8:director( name() ) ), ' :: ', m8:title( name() ) )"/>
											</a>
										</div>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
					</div>
					<xsl:message>= = = = = = = - Раздел упоминаний (END) - = = = = = =</xsl:message>
				</xsl:if>
				<xsl:message> v v v v v - Зона ссылок вниз (END) - v v v v v </xsl:message>
			</div>
		</div>
		<!--<xsl:message> newQuestName
			@@@@@ - Блоки действий (END) - @@@@@
		</xsl:message>-->
	</xsl:template>
	<!--


	-->
	<xsl:template name="quest_port">
		<xsl:param name="currentFact"/>
		<xsl:param name="currentQuest"/>
		<xsl:variable name="currentPort" select="m8:port( $fact, $currentQuest )"/>
		<xsl:variable name="predicatesThisNechto">
			<xsl:for-each select="m8:index( $startTypeName )/object/*">
				<xsl:variable name="subjectName" select="name()"/>
				<xsl:for-each select="m8:path( $startTypeName, concat( 'object_', $subjectName ) )/*">
					<xsl:for-each select="m8:port( $subjectName, name() )/*[name() != 'r' ]">
						<xsl:element name="{name()}">_</xsl:element>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="sorted_predicates">
			<xsl:for-each select="exsl:node-set($predicatesThisNechto)/*">
				<xsl:sort select="m8:title( name() )"/>
				<!--<xsl:sort select="name()"/>-->
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="final_sort">
			<xsl:apply-templates select="exsl:node-set($sorted_predicates)/*[1]" mode="predicate_grouping_new"/>
		</xsl:variable>
		<xsl:variable name="fact_n" select="m8:value( name( $factPort/n/* ) )"/>
		<!--<div>currentFact: <xsl:value-of select="$currentFact"/></div>
		<div>currentQuest: <xsl:value-of select="$currentQuest"/></div>
		<xsl:copy-of select="m8:sеrialize( $currentPort )"/>-->
		<xsl:if test="$currentQuest='n' and ( $fact_n/*[name()='svg'] or $factPort/n1459505450-5328-1 )">
			<!-- n1459505450-5328-1 = $code -->
			<style type="text/css">
				.svg_formulyar svg {
					background-color: #ccc;
					max-width: 350px !important;
					max-height: 200px !important;
				}
			</style>
			<div class="svg_formulyar" style="float: left">
				<xsl:choose>
					<xsl:when test="$fact_n/*[name()='svg']">
						<xsl:copy-of select="$fact_n/*"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="path" select="m8:img( $fact )"/>
						<xsl:choose>
							<xsl:when test="contains( $path, '.jpg' ) or contains( $path, '.png' )">
								<img src="{$path}" style="max-width: 350px"/>
							</xsl:when>
							<xsl:otherwise>
								<a href="{$path}" target="_blank">файл <xsl:value-of select="substring-after( $path, '.' )"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
		<table width="100%" style="font-size: 1em; background: #ECFFDC" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" align="center" valign="top">
					<xsl:if test="$currentPort/*[name()!='r']">
						<xsl:message>!! Левая панель: значения порта !!</xsl:message>
						<div style="padding: 1em 0em; margin: .5em" id="adminInputs">
							<!--<xsl:choose>
							<xsl:when test="$startIndex/*[name()!='subject']">-->
							<table>
								<!--<xsl:for-each select="$startPort/*[name()!='r']">-->
								<xsl:for-each select="$currentPort/*[name()!='r']">
									<xsl:sort select="name()"/>
									<xsl:variable name="pName" select="name()"/>
									<tr>
										<th valign="top" align="right">
											<a href="{ m8:root( $pName )}">
												<span style="font-size: .7em; color: black">
													<xsl:choose>
														<xsl:when test="$pName = 'i' ">имя</xsl:when>
														<xsl:when test="$pName = 'd' ">связь</xsl:when>
														<xsl:when test="$pName = 'n' ">примечание</xsl:when>
														<xsl:when test="$pName=$fact">по умолчанию</xsl:when> 
														<xsl:otherwise>
															<xsl:apply-templates select="." mode="simpleName"/>
														</xsl:otherwise>
													</xsl:choose>
												</span>
											</a>
										</th>
										<td valign="top" align="left">
											<!--<xsl:for-each select="*">-->
											<style type="text/css">
												#adminInputs select { max-width: 300px }
											</style>
											<table>
												<tr>
													<td>
														<xsl:if test="1">
															<!--$pName != 'd' or $modifier='n'-->
															<xsl:call-template name="editParamOfPort">
																<xsl:with-param name="currentFact" select="$fact"/>
																<xsl:with-param name="currentModifier" select="$currentQuest"/>
																<xsl:with-param name="predicateName" select="$pName"/>
																<xsl:with-param name="objectElement" select="$currentPort"/>
															</xsl:call-template>
														</xsl:if>
														<!--<xsl:copy-of select="m8:sеrialize( $currentPort )"/>-->
													</td>
													<td valign="top">
														<xsl:choose>
															<xsl:when test="$pName = 'd' and $currentQuest!='n' and m8:port( $modifier, $fact )/d">
																<xsl:value-of select="$symbol_replace"/>
															</xsl:when>
															<xsl:when test="$pName = 'd' and $currentQuest!='n'">
																<a href="{m8:root( $fact, $modifier )}&amp;a0={name(*/*)}&amp;m=&amp;a={$modifier}&amp;d={name( * )}" title="поменять направление связи">
																	<!--&amp;a0={m8:triple( $fact, 'd', $modifier )} &amp;fact={$fact} &amp;quest={$modifier}-->
																	<xsl:value-of select="$symbol_replace"/>
																</a>
															</xsl:when>
															<xsl:otherwise>
																<a href="{m8:root( name(*) )}">q</a>
															</xsl:otherwise>
														</xsl:choose>
													</td>
													<!--<xsl:if test="name()!='n'">-->
													<td valign="top">
														<!--<a href="{$startID}/?a0={name(*/*)}">x</a>-->
														<a href="{m8:root( $fact, $currentQuest )}&amp;a0={name(*/*)}&amp;m={$modifier}" title="удаление данного параметра">
															<xsl:value-of select="$symbol_del"/>
														</a>
													</td>
													<!--
													<td valign="top">
														<xsl:if test="$adminMode">
															<sup>
																<a href="{m8:file( name(*), 'value.xml' )}" style="color:gray; font-size:.6em">
																	<xsl:value-of select="name(*)"/>
																</a>
															</sup>
														</xsl:if>
													</td>-->
												</tr>
											</table>
											<!--</xsl:for-each>-->
										</td>
									</tr>
								</xsl:for-each>
							</table>
						</div>
					</xsl:if>
				</td>
				<td align="center" valign="top">
					<xsl:variable name="chiefName" select="m8:chief( $fact)"/>
					<xsl:if test="( m8:holder( $currentFact )=$user or m8:holder( $currentQuest )=$user ) and ( $chiefName != 'n' or $currentQuest = 'n')  or not( $types ) ">
						<!-- -->
						<!--not($modifier) or -->
						<div style="padding: 1em; ">
							<xsl:message>!! Правая панель: подсказки значений !!</xsl:message>
							<!--<div>Добавление свойства:</div>-->
							<table cellpadding="3px">
								<xsl:for-each select="exsl:node-set($final_sort)/*[name()!='n' and name()!='d' and name()!='i' ]">
									<xsl:sort select="m8:title( name() )"/>
									<tr>
										<xsl:variable name="predicate" select="name()"/>
										<td valign="top" align="center">
											<a href="{m8:root( $fact, $modifier )}&amp;{$predicate}=" title="популярность: {@count}">
												<xsl:attribute name="style"><xsl:if test="@count=1"><xsl:text>font-size: .8em</xsl:text></xsl:if></xsl:attribute>
												<xsl:apply-templates select="." mode="simpleName"/>
											</a>
										</td>
									</tr>
								</xsl:for-each>
							</table>
							<xsl:if test="$currentQuest != 'n' and m8:index( $chiefName )/quest">
								<div style="padding: .4em">------ + из мульта ------</div>
								<xsl:for-each select="m8:quest( $chiefName )/*">
									<!--<div><xsl:value-of select="name()"/></div>-->
									<xsl:variable name="linkName" select="name()"/>
									<xsl:if test="$types/@*[.=$linkName]">
										<xsl:variable name="multParam" select="name()"/>
										<div style="padding-bottom: .5em">
											<a href="{m8:root( $fact, $currentQuest )}&amp;{$types/@*[.=$multParam]}=&amp;m={$modifier}">
												<xsl:value-of select="m8:title( $multParam )"/>
												<!--<xsl:value-of select="concat( ' (', span[3], ')' )"/>
														$types/@*[name()=span[1]]  <xsl:value-of select="m8:title( $types/@*[name()=span[1]] )"/>-->
											</a>
										</div>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
							<div>------------ + ------------</div>
							<xsl:if test="not( $currentPort/i )">
								<span style="padding: .6em .8em">
									<a href="{m8:root( $fact, $currentQuest )}&amp;i=&amp;m={$modifier}" style="color: #822">имя</a>
								</span>
							</xsl:if>
							<xsl:if test="not( $currentPort/d )">
								<span style="padding: .6em .8em">
									<a href="{m8:root( $fact, $currentQuest )}&amp;d=&amp;m={$modifier}" style="color: #282">связь</a>
									<!-- &amp;quest={$modifier} модификатор не срабатывает, т.к. для d модификатор берется принудительно из квеста, а там по умолчанию 'n'-->
								</span>
							</xsl:if>
							<xsl:if test="not( $currentPort/n )">
								<span style="padding-bottom: .6em .8em">
									<a href="{m8:root( $fact, $currentQuest )}&amp;n=&amp;m={$modifier}" style="color: #228">примечание</a>
								</span>
							</xsl:if>
							<div>---------------------------</div>
							<xsl:message>
							START PORT:
							<xsl:apply-templates select="$startPort" mode="serialize"/>
							</xsl:message>
							<form action="{m8:root( $fact )}">
								<!--<input type="hidden" name="a1" value="{$fact}"/>-->
								<!--<input type="hidden" name="a4" value="n"/>-->
								<input type="hidden" name="modifier" value="{$currentQuest}"/>
								<select name="p" onchange="this.form.submit()">
									<option/>
									<!--<xsl:if test="not($startPort[name()='i'])">
									<option value="i">имя</option>
									</xsl:if>
									<xsl:if test="not($startPort[name()='d'])">
										<option value="d">описание</option>
									</xsl:if>
									<xsl:if test="not($startPort[name()='n'])">
										<option value="n">структура</option>
									</xsl:if>-->
									<xsl:if test="not( $factPort/*[name()=$fact] )">
										<option value="{$fact}">начало</option>
									</xsl:if>
									<xsl:for-each select="$types/@*">
										<xsl:sort select="m8:title( . )"/>
										<!--<xsl:variable name="typeName">
										<xsl:value-of select="name( m8:path( name(), $avatar, 'terminal' )/* )"/>
									</xsl:variable>-->
										<xsl:if test="not( $startPort/*[name()=current()] )">
											<option value="{ . }">
												<xsl:apply-templates select="." mode="simpleName"/>
											</option>
										</xsl:if>
									</xsl:for-each>
								</select>
									<input type="hidden" name="m" value="{$modifier}"/>
							</form>
						</div>
					</xsl:if>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!--

 -->
	<xsl:template name="actionElement">
		<style version="text/css">
			#circle {
			position: fixed; 
	width: 64px;
	height: 64px;
	-moz-border-radius: 32px;
	-webkit-border-radius: 32px;
	border-radius: 32px;
	#border: 4px solid gray;
	opacity: 0.6;
	font-size: 2.4em;
	line-height: 186%;
	background: green;
}
#circle a {color: yellow; }
		</style>
		<a href="{m8:root( $fact, $modifier )}&amp;a=" title="создать новый объект" style="color: white;">
			<span style="bottom: 64px; right: 64px; " id="circle">+</span>
		</a>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="predicate_grouping_new">
		<xsl:variable name="predicate" select="name()"/>
		<xsl:variable name="ref_with_this_predicate" select="../*[name() = $predicate]"/>
		<xsl:element name="{$predicate}">
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_predicate)"/></xsl:attribute>
			<xsl:text>_</xsl:text>
		</xsl:element>
		<xsl:apply-templates select="$ref_with_this_predicate[last()]/following-sibling::*[1]" mode="predicate_grouping_new"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="predicate_grouping">
		<xsl:variable name="predicate" select="name()"/>
		<xsl:variable name="ref_with_this_predicate" select="../*[name() = $predicate]"/>
		<xsl:variable name="summ_sovp" select="../*[name() = $predicate]"/>
		<xsl:element name="{$predicate}">
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_predicate)"/></xsl:attribute>
			<xsl:for-each select="$ref_with_this_predicate">
				<xsl:for-each select="*">
					<xsl:sort select="name()"/>
					<xsl:element name="{name()}">
						<xsl:attribute name="sovpadenie"><xsl:value-of select="@sovpadenie"/></xsl:attribute>
					</xsl:element>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:element>
		<!--
    Входящий список в $sorted_plain отсортирован,
    поэтому в следующую группу отправляем элемент,
    идущий за последним элементом в текущей группе
    -->
		<xsl:apply-templates select="$ref_with_this_predicate[last()]/following-sibling::*[1]" mode="predicate_grouping"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="value_grouping">
		<xsl:variable name="value" select="name()"/>
		<xsl:variable name="ref_with_this_value" select="../*[name() = $value]"/>
		<xsl:variable name="ref_with_this_value_sum_sovp" select="sum(../*[name() = $value]/@sovpadenie)"/>
		<xsl:element name="{$value}">
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_value)"/></xsl:attribute>
			<xsl:attribute name="sovpadenie"><xsl:value-of select="$ref_with_this_value_sum_sovp"/></xsl:attribute>
		</xsl:element>
		<xsl:apply-templates select="$ref_with_this_value[last()]/following-sibling::*[1]" mode="value_grouping"/>
	</xsl:template>
	<!--

	-->
</xsl:stylesheet>
