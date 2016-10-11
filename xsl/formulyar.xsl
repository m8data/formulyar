<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com">
	<xsl:output method="html" version="1.0" encoding="UTF-8"/>
	<xsl:include href="system_form.xsl"/>
	<xsl:include href="system_head.xsl"/>
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
		<xsl:call-template name="footer"/>
		<!--<div style="position: fixed; bottom: 5px; left: 5px; z-index: 1">
			<a href="{$start/@prefix}teplotn/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">calculator</a>
			<xsl:text> | </xsl:text>
			<a href="{$start/@prefix}system/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">sys</a>
			<xsl:text> | </xsl:text>
			<a href="{$start/@prefix}xalio/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">refresh</a>
			<xsl:text> | </xsl:text>
			<a href="{$start/@prefix}m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}/port.xml">xml</a>
		</div>
		<div style="position: fixed; bottom: 5px; right: 5px; color: gray; z-index: 1">
			<span title="аватар"><xsl:value-of select="$avatar"/></span>
			<xsl:text> |  </xsl:text>	
			<xsl:value-of select="$localtime"/>
			<xsl:if test="$user != 'guest' ">
				<xsl:text> |  </xsl:text>
				<xsl:value-of select="$user"/>
				<xsl:text> |  </xsl:text>
				<a href="{$start/@prefix}m8/?logout=true" style="color: red">выйти</a>
			</xsl:if>
		</div>-->
		<xsl:apply-templates select="." mode="start"/>
	</xsl:template>
	<!--

	-->
	<xsl:template name="parentLine">
		<xsl:param name="currentFactName"/>
		<xsl:param name="count"/>
		<xsl:variable name="parentQuest" select="m8:path( $currentFactName, 'subject_r' )/*/*[1]"/>
		<xsl:variable name="parentAuthorName" select="name($parentQuest/..)"/>
		<xsl:variable name="parentFactName" select="name($parentQuest)"/>
		<xsl:variable name="parentQuestName" select="name(m8:path( $parentFactName, 'subject_r' )/*/*[1])"/>
		<xsl:choose>
			<xsl:when test="$parentFactName = $currentFactName">
				<xsl:apply-templates select="m8:path( $parentFactName, $parentAuthorName, $parentQuestName, 'port' )/r/*" mode="titleWord"/>
			</xsl:when>
			<xsl:when test="10 > $count">
				<xsl:call-template name="parentLine">
					<xsl:with-param name="currentFactName" select="$parentFactName"/>
					<xsl:with-param name="count" select="$count+1"/>
				</xsl:call-template>
				<xsl:text> / </xsl:text>
				<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $parentFactName, $parentAuthorName, $parentQuestName )}">
					<xsl:apply-templates select="$parentQuest" mode="titleWord"/>
				</a>
				<xsl:text> </xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template match="port|terminal" mode="start">
		<xsl:choose>
			<xsl:when test=" $fact = 'n' ">
				<br/>
				<br/>
				<br/>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<xsl:choose>
						<xsl:when test="m8:path( $fact, 'index' )/role">
							<xsl:message terminate="no">Зеленая карта</xsl:message>
							<div style="background: #EFD; padding: 1em">
								<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх - ^ ^ ^ ^ ^ </xsl:message>
								<table style="font-size: 1em;" width="100%">
									<tr>
										<td width="30%">
											<xsl:for-each select="exsl:node-set($parent)/*">
												<xsl:if test="position()!=1">
													<xsl:text> / </xsl:text>
												</xsl:if>
												<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( name(), $avatar, name(preceding-sibling::*[1]) )}">
													<xsl:apply-templates select="." mode="simpleName"/>
												</a>
											</xsl:for-each>
										</td>
										<td width="40%" align="center" style="color: #444">
											<b>
												<xsl:apply-templates select="exsl:node-set($parent)/*[last()]/*" mode="simpleName"/>&#160;<xsl:value-of select="$fact"/>
											</b>
										</td>
										<td width="30%" align="right" valign="top">
											<xsl:choose>
												<xsl:when test="$startPort/r or 1">
													<xsl:variable name="siblings">
														<xsl:for-each select="m8:path( $typeName, 'index' )/object/*">
															<xsl:sort select="@time"/>
															<xsl:copy/>
														</xsl:for-each>
													</xsl:variable>
													<!--<div>typeName: <xsl:value-of select="$typeName"/></div>
													<xsl:apply-templates select="exsl:node-set($siblings)/*" mode="serialize"/>-->
													<xsl:if test="exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*">
														<xsl:variable name="predName" select="name(exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*[1])"/>
														<a href="{$start/@prefix}a/{$ctrl}/m8/{substring($predName,1,1)}/{$predName}">
															<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*[1]" mode="simpleName"/>&#9668;</a>
													</xsl:if>
													<xsl:choose>
														<xsl:when test="$startTypeName = 'r' ">&#160;&#160;X&#160;&#160;</xsl:when>
														<xsl:otherwise>
															<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $startTypeName) }">&#160;&#160;X&#160;&#160;</a>
														</xsl:otherwise>
														<!--, $author, $quest -->
													</xsl:choose>
													<xsl:if test="exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*">
														<xsl:variable name="nextName" select="name(exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*[1])"/>
														<a href="{$start/@prefix}a/{$ctrl}/m8/{substring($nextName,1,1)}/{$nextName}">&#9658;<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*[1]" mode="simpleName"/>
														</a>
													</xsl:if>
												</xsl:when>
												<xsl:otherwise>
													<a href="{$start/@prefix}a/{$ctrl}/">X</a>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
								</table>
								<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх (END) - ^ ^ ^ ^ ^ </xsl:message>
								<br/>
								<xsl:call-template name="quest_port"/>
								<br style="clear: both"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Красная карта</xsl:message>
							<div style="margin: 2em; padding: 1em; background: #FED">
								<div style="float: right">
									<a href="{$start/@prefix}a/{$ctrl}/">X</a>
								</div>
								<br style="clear: both"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<div style="padding: 3em" id="linkDownZone">
			<xsl:message> v v v v v - Зона ссылок вниз - v v v v v </xsl:message>
			<table width="100%" style="font-size: .9em;">
				<tr>
					<td align="center" valign="top" width="25%">
						<xsl:for-each select="m8:path( 'r', 'role2' )/*/*[name()=$fact]">
							<xsl:variable name="actionAuthor" select="name(..)"/>
							<xsl:if test="m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact]"><!--[name(*) != $fact]-->
								<xsl:variable name="firstTypeName" select="name( m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact][1]/*)"/>
								<xsl:variable name="protoTypeName" select="name( m8:path( $firstTypeName, $avatar, $firstTypeName, 'port' )/r/*)"/>
								<!--<xsl:attribute name="style">display: normal</xsl:attribute>-->
								<b style="color: #555">Состав
									</b>
								<div style="padding: 1em">
									<xsl:for-each select="m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact]">
										<xsl:sort select="*/*/@time"/>
										<xsl:variable name="currentType" select="m8:path( name(), $actionAuthor, $fact, 'port' )/r/*"/>
										<xsl:if test="name($currentType) != $fact">
										<div style="padding: .2em">
											<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( name(), $actionAuthor, $fact )}">
												<xsl:value-of select="position()"/>.
													<xsl:text> </xsl:text>
												<!--<xsl:apply-templates select="m8:path( name(), $actionAuthor, $fact, 'port' )/r/*" mode="simpleName"/>
												<xsl:text> </xsl:text>
												
												<xsl:value-of select="name()"/>-->
												<!--<xsl:apply-templates select="m8:path( name(), $avatar, $fact, 'port' )/i/*" mode="simpleName"/>-->
												<xsl:apply-templates select="$currentType" mode="simpleName"/>
												<xsl:text> :: </xsl:text>
												<xsl:apply-templates select="." mode="simpleName"/>
											</a>
										</div>
										</xsl:if>
									</xsl:for-each>
									<!--<div>
										<xsl:text>+</xsl:text>
										<form action="{concat( $start/@prefix, 'a/', $ctrl, '/', m8:dir( $fact ) )}">
											<select name="r" onchange="this.form.submit()">
												<option/>
												<xsl:for-each select="m8:path( 'r', concat( 'predicate_', $protoTypeName ) )/*[name()=$avatar]/*">
													<xsl:sort select="@time"/>
													<xsl:variable name="currentMatter" select="name()"/>
													<xsl:if test="not( m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact][name(*) = $currentMatter] )">
														<option value="{name()}">
															<xsl:apply-templates select="." mode="titleWord"/>
														</option>
													</xsl:if>
												</xsl:for-each>
											</select>
										</form>
									</div>-->
								</div>
							</xsl:if>
						</xsl:for-each>
					</td>
					<xsl:if test="m8:path( $fact,  'index' )/object/*">
						<td align="center" valign="top" width="50%">
							<b>Экземпляры <!--"<xsl:apply-templates select="$start" mode="titleWord"/>"-->
							</b>
							<div style="padding: 1em">
								<xsl:for-each select="m8:path( $fact, 'index' )/object/*">
									<xsl:sort select="@time"/>
									<xsl:variable name="subject" select="."/>
									<xsl:variable name="subjectName" select="name()"/>
									<xsl:variable name="position" select="position()"/>
									<xsl:variable name="currentQuest" select="name(m8:path( name(), 'subject_r' )/*/*)"/>
									<xsl:if test="$currentQuest = $fact">
										<div style="font-size: 1.4em; padding: .1em">
											<a href="{$start/@prefix}a/{$ctrl}/{ m8:dir( $subjectName )}"><!--, $avatar, 'n'-->
												<xsl:apply-templates select="$subject" mode="simpleName"/>
											</a>
										</div>
									</xsl:if>
									<!--<xsl:for-each select="m8:path( $fact, concat( '/object_', $subjectName ) )/*[name()=$user]/*[name()=$subjectName]">
										<xsl:sort select="name(..)"/>
										<xsl:variable name="currentAuthorName" select="name(..)"/>
										<xsl:variable name="currentQuestName" select="name()"/>
										<div style="font-size: 1.4em; padding: .1em">
											<a href="{$start/@prefix}a/{$ctrl}/{ m8:dir( $subjectName, $currentAuthorName )}">
												<xsl:value-of select="$position"/>
												<xsl:text>. </xsl:text>
												<xsl:if test="$author != $currentAuthorName">
													<xsl:apply-templates select=".." mode="simpleName"/>
													<xsl:text> :: </xsl:text>
												</xsl:if>
												<xsl:apply-templates select="$subject" mode="simpleName"/>
											</a>
											<xsl:if test="$currentAuthorName='guest'">
												<xsl:if test="1200 > $time - @time">&#160;<sup style="color: red">new</sup>
												</xsl:if>
												<xsl:if test="120 > $time - m8:path( $currentQuestName, 'role1' )/*[name()=$currentAuthorName]/*/@time">
													<xsl:text> </xsl:text>
													<sup style="color: magenta">change</sup>
													<embed src="{$start/@prefix}xalio/mp3/message.mp3" autostart="true" hidden="true" loop="true" width="0" height="0" align="bottom"> </embed>
												</xsl:if>
											</xsl:if>
										</div>
									</xsl:for-each>-->
								</xsl:for-each>
							</div>
						</td>
						<td align="center" valign="top" width="25%">
							<div style="display: normal">
								<b style="color: #555">Ассоциации <!--"<xsl:apply-templates select="$start" mode="titleWord"/>"-->
								</b>
								<xsl:for-each select="m8:path( $fact, 'index' )/object/*">
									<xsl:sort select="@time"/>
									<xsl:variable name="subject" select="."/>
									<xsl:variable name="subjectName" select="name()"/>
									<xsl:variable name="position" select="position()"/>
									<xsl:variable name="currentQuest" select="name(m8:path( name(), 'subject_r' )/*/*)"/>
									<xsl:if test="$currentQuest != $fact">
										<div style="font-size: 1.2em; padding: .1em">
											<a href="{$start/@prefix}a/{$ctrl}/{ m8:dir( $subjectName )}">
												<xsl:value-of select="$position"/>
												<xsl:text>. </xsl:text>
												<!--<xsl:if test="$author != $currentAuthorName">
												<xsl:apply-templates select=".." mode="simpleName"/>
												<xsl:text> :: </xsl:text>
											</xsl:if>-->
												<xsl:apply-templates select="$subject" mode="simpleName"/>
											</a>
										</div>
									</xsl:if>
									<!--<xsl:for-each select="m8:path( $fact, concat( '/object_', $subjectName ) )/*[name()=$user]/*[name()!=$subjectName]">
										<xsl:sort select="name(..)"/>
										<xsl:variable name="currentAuthorName" select="name(..)"/>
										<xsl:variable name="currentQuestName" select="name()"/>
										<div style="font-size: 1.2em; padding: .1em">
											<a href="{$start/@prefix}a/{$ctrl}/m8/{substring($subjectName,1,1)}/{$subjectName}/{$currentAuthorName}/{$currentQuestName}">
												<xsl:value-of select="$position"/>
												<xsl:text>. </xsl:text>
												<xsl:if test="$author != $currentAuthorName">
													<xsl:apply-templates select=".." mode="simpleName"/>
													<xsl:text> :: </xsl:text>
												</xsl:if>
												<xsl:apply-templates select="$subject" mode="simpleName">
													<xsl:with-param name="quest" select="$currentQuestName"/>
												</xsl:apply-templates>
											</a>
										</div>
									</xsl:for-each>-->
								</xsl:for-each>
							</div>
							<br/>
							<br/>
							<br/>
							<br/>
						</td>
					</xsl:if>
					<!--<td align="center" valign="top">
						<xsl:if test="m8:path( $fact,  'index' )/object/*">
							
						</xsl:if>
					</td>-->
				</tr>
			</table>
			<xsl:message> v v v v v - Зона ссылок вниз (END) - v v v v v </xsl:message>
		</div>
		<div style="color: #777">
			<xsl:message>= = = = = = = - Зона упоминаний - = = = = = =</xsl:message>
			<xsl:if test="m8:path( $fact, 'index' )/role/role1">
				<div>
					<b>Упоминания в роли значения</b>
					<xsl:for-each select="m8:path( $fact, 'role3' )/*[name()=$user]/*">
						<xsl:sort select="@time"/>
						<div>
							<a href="{$start/@prefix}a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}/{name(..)}" style="color: gray">
								<xsl:apply-templates select="." mode="simpleName"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="m8:path( $fact, 'index' )/role/role2">
				<br/>
				<div>
					<b>Упоминания в роли параметра</b>
					<xsl:for-each select="m8:path( $fact, 'role2' )/*[name()=$user]/*">
						<xsl:sort select="@time"/>
						<xsl:variable name="cAuthor" select="name(..)"/>
						<xsl:variable name="cQuest" select="name()"/>
						<div>
							<xsl:for-each select="m8:path( $fact, $cAuthor, $cQuest, 'dock' )/*">
								<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( name(), $cAuthor, $cQuest )}" style="color: gray">
									<xsl:apply-templates select="." mode="simpleName"/>
								</a>
							</xsl:for-each>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="m8:path( $fact, 'index' )/role/role1">
				<br/>
				<div>
					<b>Упоминания в роли субъекта</b>
					<xsl:for-each select="m8:path( $fact, 'role1' )/*[name()=$user]/*[name()!=$fact]">
						<xsl:sort select="@time"/>
						<div>
							<a href="{$start/@prefix}a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}/{name(..)}" style="color: gray">
								<xsl:apply-templates select="." mode="simpleName"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="m8:path( $fact, 'quest' )/*/*">
				<br/>
				<div>
					<b>Упоминания в роли квеста</b>
					<xsl:for-each select="m8:path( $fact, 'quest' )/*[name()=$user]/*[name()!=$fact]">
						<xsl:sort select="@time"/>
						<div>
							<a href="{$start/@prefix}a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}/{name(..)}/{$fact}" style="color: gray">
								<xsl:apply-templates select="." mode="simpleName"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:message>= = = = = = = - Зона упоминаний (END) - = = = = = =</xsl:message>
		</div>
		<xsl:message> 
									@@@@@ - Зона генерации нового - @@@@@
				</xsl:message>
		<!--<div style="position: fixed; bottom: 50px; left: 50px; font-size: 2em; background-color: green; opacity: 0.5; padding: 1em; padding-bottom: 0; border-radius: 2em; ">
			<form action="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact )}/">
				<span style="font-size: 11pt; color: white">Добавить: </span>
				<input type="hidden" name="quest" value="{$fact}"/>
				<select name="a" onchange="this.form.submit()">
					<option/>
					<xsl:for-each select="m8:path( 'r', 'predicate_n' )/*/*">
						<option value="{name()}">
							<xsl:apply-templates select="." mode="titleWord"/>
						</option>
					</xsl:for-each>
				</select>
			</form>
		</div>-->
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
		<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact )}/?a=" title="создать новый объект" style="color: white;">
		<span style="bottom: 64px; right: 64px; " id="circle">+</span></a>
		<!--<div style="bottom: 70px; right: 165px; " id="circle">
			<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact )}/?a=" title="реплицировать внутрь" style="color: purple">&#9632;</a>
		</div>
		<div style="bottom: 70px; right: 70px; font-size: 4.7em; line-height: 64%;" id="circle">
			<a href="{$start/@prefix}a/{$ctrl}/?a=" title="реплицировать на свободу" style="color: red">&#9679;</a>
		</div>-->
		<xsl:message> newQuestName
			@@@@@ - Зона генерации нового (END) - @@@@@
		</xsl:message>
	</xsl:template>
	<!--


	-->
	<xsl:template name="quest_port">
		<xsl:variable name="predicatesThisNechto">
			<xsl:for-each select="m8:path( $startTypeName, 'index' )/object/*">
				<xsl:variable name="subjectName" select="name()"/>
				<xsl:for-each select="m8:path( $startTypeName, concat( 'object_', $subjectName ) )/*/*">
					<xsl:for-each select="m8:path( $subjectName, name(..), name(), 'port' )/*[name() != 'r' ]">
						<xsl:element name="{name()}">_</xsl:element>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="sorted_predicates">
			<xsl:for-each select="exsl:node-set($predicatesThisNechto)/*">
				<xsl:sort select="name()"/>
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="final_sort">
			<xsl:apply-templates select="exsl:node-set($sorted_predicates)/*[1]" mode="predicate_grouping_new"/>
		</xsl:variable>
		<table width="100%" style="font-size: 1em">
			<tr>
				<td align="center" valign="top">
					<xsl:message>!! Левая панель: значения порта !!</xsl:message>
					<div style="padding: 1em; margin: .5em">
						<xsl:choose>
							<xsl:when test="$startIndex/*[name()!='subject']">
								<table>
									<xsl:for-each select="$startPort/*[name()!='r']">
										<xsl:sort select="name()"/>
										<xsl:variable name="pName" select="name()"/>
										<tr>
											<th valign="top" align="right">
												<a href="{$start/@prefix}a/{$ctrl}/m8/{substring($pName,1,1)}/{$pName}">
													<span style="font-size: .8em; color: black">
														<xsl:choose>
															<xsl:when test="$pName = 'i' ">имя</xsl:when>
															<xsl:when test="$pName = 'n' ">файл</xsl:when>
															<xsl:when test="$pName = 'd' ">описание</xsl:when>
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
												<table>
													<tr>
														<td>
															<xsl:call-template name="editParamOfPort">
																<xsl:with-param name="predicateName" select="$pName"/>
																<xsl:with-param name="objectElement" select="$startPort"/>
															</xsl:call-template>
														</td>
														<td valign="top">
															<a href="{$start/@prefix}a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}">q</a>
														</td>
														<!--<xsl:if test="name()!='n'">-->
														<td valign="top">
															<a href="{$startID}/?a0={name(*/*)}">x</a>
														</td>
														<!--</xsl:if>-->
														<td valign="top">
															<xsl:if test="$adminMode">
																<sup>
																	<a href="{$start/@prefix}m8/{substring(name(),1,1)}/{name()}/value.xml" style="color:gray; font-size:.6em">
																		<xsl:value-of select="name()"/>
																	</a>
																</sup>
															</xsl:if>
														</td>
													</tr>
												</table>
												<!--</xsl:for-each>-->
											</td>
										</tr>
									</xsl:for-each>
								</table>
								<div style="background: #ded; padding: 1em; opacity: 0.75; position: absolute; left:0; bottom: 4em">
									<xsl:message>				-- Вывод пульта навигации --</xsl:message>
									<xsl:variable name="parentPort" select="m8:path( $fact, $author, $parentName, 'port' )"/>
									<xsl:variable name="newQuestName">
										<xsl:choose>
											<xsl:when test="exsl:node-set($parent)/*[last()-1]"><xsl:value-of select="name( exsl:node-set($parent)/*[last()-1] )"/></xsl:when>
											<xsl:otherwise>n</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<table cellpadding="0">										
										<tr>
											<td valign="top">
												<span style="font-size: .8em; color: black">составление</span>
											</td>
											<td valign="top">
												<xsl:call-template name="editParamOfPort">
													<xsl:with-param name="predicateName" select="'modifier'"/>
													<xsl:with-param name="objectElement" select="m8:path( $typeName, $user, 'port' )"/>
													<xsl:with-param name="action" select="concat( $start/@prefix, 'a/', $ctrl, '/', m8:dir( $fact, $user ) )"/>
													<xsl:with-param name="hidden">
														<r><xsl:value-of select="$typeName"/></r>
													</xsl:with-param>
												</xsl:call-template>
											</td>
											<td valign="top">
												
												<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact, $user )}/?r={$typeName}&amp;modifier={ $newQuestName }" title="to new Quest - { $newQuestName }">^</a>
											</td>
										</tr>	
										<tr>
											<td valign="top">
												<span style="font-size: .9em; color: black">перемещение</span>
											</td>
											<td valign="top">
												<xsl:call-template name="editParamOfPort">
													<xsl:with-param name="predicateName" select="'modifier'"/>
													<xsl:with-param name="objectElement" select="m8:path( $typeName, $user, 'port' )"/>
													<xsl:with-param name="action" select="concat( $start/@prefix, 'a/', $ctrl, '/', m8:dir( $fact, $user ) )"/>
													<xsl:with-param name="hidden">
														<r><xsl:value-of select="$typeName"/></r>
														<object><xsl:value-of select="$newQuestName"/></object>
													</xsl:with-param>
												</xsl:call-template>
											</td>
											<td valign="top">
												<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact, $user )}/?r={$typeName}&amp;modifier={$newQuestName}&amp;object={$newQuestName}" title="to new Quest - { $newQuestName } COMMON">^</a>
											</td>
										</tr>										
										<tr>
											<td valign="top">
												<span style="font-size: .8em; color: black" title="подчинение">объединение</span>
											</td>
											<td valign="top">
												<xsl:call-template name="editParamOfPort">
													<xsl:with-param name="predicateName" select="'r'"/>
													<xsl:with-param name="objectElement" select="m8:path( $typeName, $user, 'port' )"/>
													<xsl:with-param name="action" select="concat( $start/@prefix, 'a/', $ctrl, '/', m8:dir( $fact, $user ) )"/>
													<xsl:with-param name="hidden">
														<modifier><xsl:value-of select="$parentName"/></modifier>
													</xsl:with-param>
												</xsl:call-template>
											</td>
											<td valign="top">
												<xsl:variable name="typePosition" select="count( exsl:node-set($parent)/*[name(*)=$typeName][position()=1]/preceding-sibling::* )"/>
												<xsl:variable name="newTypeName">
													<xsl:choose>
														<xsl:when test="$typePosition"><xsl:value-of select="name( exsl:node-set($parent)/*[$typePosition]/* )"/></xsl:when>
														<xsl:otherwise>n</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact, $user )}/?r={$newTypeName}&amp;modifier={$parentName}" title="to new typePosition - {$typePosition} / newTypeName - { $newTypeName }">^</a>
											</td>
										</tr>
									
									</table>
									<xsl:message>				-- Вывод пульта навигации (END) --
									</xsl:message>												
									<a href="{$start/@prefix}a/{$ctrl}/{m8:dir($parentName)}/?a0={name($parentPort/r/*/*)}&amp;a4={$parentName}" style="color: #222">удаление</a>
								</div>
							</xsl:when>
							<xsl:otherwise>
								<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $factTypeName )}/?a0={name($startPort/r/*/*)}&amp;a5={$quest}">удалить объект</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</td>
				<td align="center" valign="top">
					<div style="padding: 1em; ">
						<xsl:message>!! Правая панель: подсказки значений !!</xsl:message>
						<table cellpadding="3px">
							<xsl:for-each select="exsl:node-set($final_sort)/*">
								<xsl:sort select="@count" order="descending"/>
								<tr>
									<xsl:variable name="predicate" select="name()"/>
									<td valign="top" align="center">
										<a href="{$startID}/?a2={$predicate}" title="популярность: {@count}">
											<xsl:attribute name="style"><xsl:if test="@count=1"><xsl:text>font-size: .8em</xsl:text></xsl:if></xsl:attribute>
											<xsl:apply-templates select="." mode="simpleName"/>
										</a>
									</td>
								</tr>
							</xsl:for-each>
						</table>
						<br/>Добавление свойства:
					<form action="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact, $user )}">
						<!--<input type="hidden" name="a1" value="{$fact}"/>-->
						<!--<input type="hidden" name="a4" value="n"/>-->
							<input type="hidden" name="a3" value="r"/>
							<select name="a2" onchange="this.form.submit()">
								<option/>
								<xsl:if test="not($startPort[name()='i'])">
									<option value="i">имя</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()='d'])">
									<option value="d">описание</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()='n'])">
									<option value="n">структура</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()=$fact])">
									<option value="{$fact}">начало</option>
								</xsl:if>
								<xsl:for-each select="m8:path( $avatar )/*">
									<xsl:sort select="@name"/>
									<xsl:variable name="typeName">
										<xsl:value-of select="name( m8:path( name(), 'role3' )/*[name()=$avatar]/* )"/>
									</xsl:variable>
									<option value="{$typeName}">
										<xsl:apply-templates select="m8:path( name(), 'role3' )/*[name()=$avatar]/*" mode="simpleName"/>
									</option>
								</xsl:for-each>
							</select>
						</form>
					</div>
				</td>
			</tr>
		</table>
		<!-- -->
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
