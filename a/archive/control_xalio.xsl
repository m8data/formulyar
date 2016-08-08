<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common">
	<!--<xsl:param name="predicates" select="document( '/m8/r/r/n.xml' )/*/*[name()=$author]/*[name()=$avatar]"/>-->

	<!--

	-->
	<xsl:template name="Head2">
		<script src="/system/a/js/book/jquery.min.js"/>
		<script>var source = "";</script>
		<!-- по какой-то причине, если не втавить этот тэг, то предыдущий открывающий тег скрипта не закроется //-->
		<script src="/system/a/js/xalio.js"/>
		<script>var source2 = "";</script>
		<!-- <script type="text/javascript">
		$(document).ready(function() {	
			//alert('aa');
			$('.input').change(function() {	
				alert('ss'); //<xsl:value-of select="$questID"/>/
				var formData = $(this).serialize();		
				$.get('.',formData,processData).error('ой');		
				function processData(data) {			
					console.log(data==='pass');			
					if (data==='pass') {			   
						$('.main').html('<p>Вы авторизованы!</p>');			
					} else {				
						if ($('#fail').length === 0) {					
							$('#formwrapper').prepend('<p id="fail">Некорректная  информация. Попробуйте еще раз</p>');				
						}			
					}		
				} // end processData		return false;	
			}); // end submit	
		}); // end ready
		</script> //-->
	</xsl:template>
	<!--

	-->
	<xsl:template name="parentLine">
		<xsl:param name="currentFactName"/>
		<xsl:param name="count"/>
		<xsl:variable name="parentQuest" select="document( concat( '/m8/', substring($currentFactName,1,1), '/', $currentFactName, '/subject_r.xml' ) )/*/*/*/*[1]"/>
		<xsl:variable name="parentAvatarName" select="name($parentQuest/..)"/>
		<xsl:variable name="parentAuthorName" select="name($parentQuest/../..)"/>
		<xsl:variable name="parentFactName" select="name($parentQuest)"/>
		<xsl:variable name="parentQuestName" select="name(document( concat( '/m8/', substring($parentFactName,1,1), '/', $parentFactName, '/subject_r.xml' ) )/*/*/*/*[1])"/>
		<xsl:variable name="parentFactPrefix" select="substring($parentFactName,1,1)"/>
		<xsl:choose>
			<xsl:when test="$parentFactName = $currentFactName">
				<xsl:apply-templates select="document ( concat( '/m8/', $parentFactPrefix, '/', $parentFactName, '/', $parentAuthorName, '/', $parentAvatarName, '/', $parentQuestName, '/port.xml' ) )/*/r/*" mode="titleWord"/>
			</xsl:when>
			<xsl:when test="10 > $count">
				<xsl:call-template name="parentLine">
					<xsl:with-param name="currentFactName" select="$parentFactName"/>
					<xsl:with-param name="count" select="$count+1"/>
				</xsl:call-template>
				<xsl:text> / </xsl:text>
				<a href="/m8/{$parentFactPrefix}/{$parentFactName}/{$parentAuthorName}/{$parentAvatarName}/{$parentQuestName}">
					<xsl:apply-templates select="$parentQuest" mode="titleWord"/>
				</a>
				<xsl:text> </xsl:text>
			</xsl:when>
			<!--//-->
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template match="port" mode="start">
		<xsl:choose>
			<xsl:when test="$fact != 'i' ">
				<!--<xsl:if test="$author != 'guest'">
				<div style="position: absolute; bottom: 10px; left: 10px; font-color: gray">
					<a href="{$questID}/{$avatar}/{$avatar}/{$quest}/port.xml">xml</a>
				</div>				
				</xsl:if>-->
				<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх - ^ ^ ^ ^ ^ </xsl:message>
				<xsl:choose>
					<xsl:when test="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/index.xml' ) )/*/role/role1">
						<xsl:message>Зеленая карта</xsl:message>
						<div style="margin: 2em; padding: 1em; background: #EFD">
							<table style="font-size: 1em" width="100%">
								<tr>
									<td>
										<xsl:value-of select="$author"/>
										<xsl:text>: </xsl:text>
										<xsl:if test="$quest != $fact">
											<xsl:call-template name="parentLine">
												<xsl:with-param name="count" select="0"/>
												<xsl:with-param name="currentFactName" select="$fact"/>
											</xsl:call-template>
										</xsl:if>
									</td>
									<td width="20%"> </td>
									<td align="right" valign="top">
										<xsl:choose>
											<xsl:when test="$startPort/r">
												<a href="{concat( '/m8/', substring($startTypeName,1,1), '/', $startTypeName ) }">
													<!--<xsl:apply-templates select="$startPort/r/*" mode="titleWord"/> > -->X</a>
											</xsl:when>
											<xsl:otherwise>
												<a href="/">X</a>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</tr>
							</table>
							<div>
								<h4>
									<xsl:apply-templates select="$startPort/r/*" mode="titleWord"/>
									<!--<xsl:value-of select="$typeName"/>-->
									<xsl:text> </xsl:text>
									<xsl:value-of select="$fact"/><!--<a href="/m8/{substring($fact,1,1)}/{$fact}" style="color:black"></a>-->
									
								</h4>
								<!--(автор: <xsl:value-of select="$author"/>)-->
							</div>
							<div style="clear: both"/>
							<xsl:call-template name="quest_port"/>
							<!--<xsl:apply-templates select="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/', $author, '/', $avatar, '/', $quest, '/port.xml' ) )/*" mode="quest_port"/>-->
							<br style="clear: both"/>
							<!--</xsl:for-each>-->
						</div>
					</xsl:when>
					<!--<xsl:when test="$action_types[name()=$quest]">
Не сконструировано
					</xsl:when>-->
					<xsl:otherwise>
						<xsl:message>Красная карта</xsl:message>
						<div style="margin: 2em; padding: 1em; background: #FED">
							<div style="float: right">
								<a href="/">X</a>
							</div>
							<br style="clear: both"/>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:message> v v v v v - Зона ссылок вниз - v v v v v </xsl:message>
				<table width="100%" style="font-size: .9em">
					<tr>
						<td align="center" valign="top">
							<xsl:for-each select="document( '/m8/r/r/role2.xml' )/*/*/*[name()=$avatar]/*[name()=$fact]">
								<xsl:variable name="actionAuthor" select="name(../..)"/>
								<xsl:if test="document( concat( '/m8/r/r/', $actionAuthor, '/', $avatar, '/', $fact, '/role2.xml' ) )/*/*[@p1 != $fact]">
									<b>Внутренние сущности
									</b>
									<div style="padding: 1em">
										<xsl:for-each select="document( concat( '/m8/r/r/', $actionAuthor, '/', $avatar, '/', $fact, '/role2.xml' ) )/*/*[@p1 != $fact]">
											<xsl:sort select="@time"/>
											<div>
												<a href="/m8/{substring(@p1,1,1)}/{@p1}/{$actionAuthor}/{$avatar}/{$fact}">
													<xsl:value-of select="position()"/>.
													<xsl:text> </xsl:text>
													<xsl:apply-templates select="@p1" mode="titleWord_withType">
														<xsl:with-param name="currentAuthorName" select="$actionAuthor"/>
														<xsl:with-param name="currentQuestName" select="$fact"/>
													</xsl:apply-templates>
												</a>
											</div>
										</xsl:for-each>
									</div>
								</xsl:if>
							</xsl:for-each>
						</td>
						<td align="center" valign="top">
							<xsl:if test="document( concat( '/m8/', substring($fact,1,1), '/', $fact,  '/index.xml' ) )/*/object/*">
								<b>Экземпляры "<xsl:apply-templates select="$temp" mode="titleWord"/>"</b>
								<div style="padding: 1em">
									<xsl:for-each select="document( concat( '/m8/', substring($fact,1,1), '/', $fact,  '/index.xml' ) )/*/object/*">
										<xsl:sort select="@time"/>
										<xsl:variable name="subject" select="."/>
										<xsl:variable name="subjectName" select="name()"/>
										<xsl:variable name="position" select="position()"/>
										<xsl:for-each select="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/object_', $subjectName,  '.xml' ) )/*/*/*[name()=$avatar]/*">
											<!--/*/*[name()=$actionAuthor]/*[name()=$avatar]/*-->
											<xsl:sort select="name(../..)"/>
											<xsl:variable name="currentAuthorName" select="name(../..)"/>
											<xsl:variable name="currentQuestName" select="name()"/>
											<div>
												<a href="/m8/{substring($subjectName,1,1)}/{$subjectName}/{$currentAuthorName}/{$avatar}/{$currentQuestName}">
													<xsl:value-of select="$position"/>.<xsl:value-of select="position()"/>.
												<!--<xsl:variable name="typeQuest" select="document ( concat( '/m8/', substring($currentQuest,1,1), '/', $currentQuest, '/', $avatar, '/', $avatar, '/', $currentQuest, '/port.xml' ) )/*/r/*"/>
												<xsl:if test="name($typeQuest) != $fact">
													<xsl:text> </xsl:text>
													<xsl:apply-templates select="$typeQuest" mode="titleWord"/>
												</xsl:if>-->
													<xsl:text> </xsl:text>
													<xsl:if test="$subjectName != $currentQuestName">
														<xsl:apply-templates select="." mode="titleWord"/>
														<xsl:text> :: </xsl:text>
													</xsl:if>
													<xsl:if test="$author != $currentAuthorName">
														<xsl:apply-templates select="../.." mode="titleWord"/>
														<xsl:text> :: </xsl:text>
													</xsl:if>
													<xsl:apply-templates select="$subject" mode="titleWord">
														<xsl:with-param name="currentAuthorName" select="$currentAuthorName"/>
														<xsl:with-param name="currentQuestName" select="$currentQuestName"/>
													</xsl:apply-templates>
												</a>
											</div>
										</xsl:for-each>
									</xsl:for-each>
								</div>
							</xsl:if>
						</td>
					</tr>
				</table>
				<xsl:message> @@@@@ - Зона генерации нового - @@@@@</xsl:message>
				<div style="position: absolute; bottom: 50px; left: 50px; font-size: 2em; background-color: green; opacity: 0.5; padding: 1em; padding-bottom: 0; border-radius: 2em; ">
					<form>
						<xsl:choose>
							<xsl:when test="document( concat( '/m8/', substring($startTypeName,1,1), '/', $startTypeName,  '/index.xml' ) )/*/object/*[name()!=$fact] and $fact!=$quest">
								<xsl:variable name="parentFact" select="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/subject_r.xml' ) )/*/*/*/*[1]"/>
								<xsl:variable name="parentFactName" select="name($parentFact)"/>
								<xsl:variable name="parentFactPrefix" select="substring($parentFactName,1,1)"/>
								<xsl:variable name="parentQuestName" select="name(document( concat( '/m8/', substring($parentFactName,1,1), '/', $parentFactName, '/subject_r.xml' ) )/*/*/*/*[1])"/>
							
								<xsl:attribute name="action"><xsl:value-of select="$questID"/><xsl:text>/</xsl:text></xsl:attribute><!--<xsl:value-of select="concat( '/m8/', substring($parentFactName,1,1), '/', $parentFactName,  '/', $author, '/' )"/>-->
								<xsl:comment>Здесь нельзя указывать просто текущий путь т.к. он может включать родительский квест, а нам как раз нужно использовать текущий</xsl:comment>
								<select name="r" onchange="this.form.submit()">
									<option/>
									<xsl:for-each select="document( concat( '/m8/', substring($startTypeName,1,1), '/', $startTypeName,  '/index.xml' ) )/*/object/*[name()!=$fact]">
										<xsl:sort select="@time"/>
										<!--<xsl:variable name="subject" select="name()"/>
										<xsl:variable name="position" select="position()"/>
										<xsl:for-each select="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/', $subject,  '.xml' ) )/*/*/*[name()=$avatar]/*">
											<xsl:sort select="name(../..)"/>
											<xsl:variable name="currentAuthor" select="name(../..)"/>
											<xsl:variable name="currentQuest" select="name()"/>-->
										<option value="{name()}">
											<xsl:apply-templates select="." mode="titleWord"/>
										</option>
									</xsl:for-each>
								</select>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="action"><xsl:value-of select="concat( '/m8/', substring($fact,1,1), '/', $fact,  '/', $author, '/' )"/></xsl:attribute>
								<select name="r" onchange="this.form.submit()">
									<option/>
									<xsl:for-each select="document( '/m8/r/r/predicate_n.xml' )/*/*[name()=$avatar]/*[name()=$avatar]/*">
										<option value="{name()}">
											<xsl:apply-templates select="." mode="titleWord"/>
										</option>
									</xsl:for-each>
								</select>
							</xsl:otherwise>
						</xsl:choose>
					</form>
				</div>
				<!--</xsl:if>-->
				<div style="position: absolute; bottom: 50px; right: 50px; font-size: 2em; background-color: green; width: 2em; height: 2em; border-radius: 2em; padding-top: .2em; padding-right: .2em; opacity: 0.5">
				<xsl:choose>
					<xsl:when test="$fact!=$quest">
				
					<a style="color: white; margin-top: auto" href="{$questID}/?r={$fact}">+</a>
					</xsl:when>
					<xsl:otherwise>
						<a style="color: white; margin-top: auto" href="/m8/?r={$fact}">+</a>
					</xsl:otherwise>
				</xsl:choose>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div style="padding: 1em">
					<div style="padding: 1em">
						<b>Имеющиеся в системе данные</b>
					</div>
					<xsl:for-each select="document( '/m8/r/r/index.xml' )/*/predicate/*">
						<div>
							<a href="/m8/{substring(name(),1,1)}/{name()}">
								<xsl:apply-templates select="." mode="titleWord"/>
								<!--<xsl:value-of select="name()"/>-->
							</a>
						</div>
					</xsl:for-each>
					<!--<xsl:if test="not($action_types)">
					<div style="position: absolute; bottom: 50px; right: 50px; font-size: 2em">
						<a href="/m8/?_=i">НАЧАТЬ</a>
					</div>
					</xsl:if>-->
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--


<xsl:template match="port" mode="quest_port">
	-->
	<xsl:template name="quest_port">
		<xsl:variable name="predicatesThisNechto">
			<xsl:for-each select="document( concat( '/m8/', substring($startTypeName,1,1), '/', $startTypeName,  '/index.xml' ) )/*/object/*">
				<xsl:variable name="subjectName" select="name()"/>
				<xsl:for-each select="document( concat( '/m8/', substring($startTypeName,1,1), '/', $startTypeName, '/object_', $subjectName,  '.xml' ) )/*/*/*[name()=$avatar]/*">
					<xsl:for-each select="document( concat( '/m8/', substring($subjectName,1,1), '/', $subjectName, '/', name(../..), '/', $avatar, '/', name(), '/port.xml' ) )/*/*[name() != 'r' ]">
						<xsl:element name="{name()}">_</xsl:element>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<!--[predicatesThisNechto <code>
			<xsl:copy-of select="$predicatesThisNechto"/>
		</code>] //-->
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
							<xsl:when test="$startPort/*[name() != 'r']">
								<table>
									<xsl:for-each select="$startPort/*[name() != 'r']">
										<xsl:sort select="name()"/>
										<xsl:variable name="pName" select="name()"/>
										<tr>
											<th valign="top" align="right">
												<a href="/m8/{substring($pName,1,1)}/{$pName}">
													<!-- /{$avatar}/{$avatar}/{$pName}/port.xml -->
													<span style="font-size: .8em; color: black">
														<xsl:apply-templates select="." mode="titleWord"/>
													</span>
												</a>
											</th>
											<td valign="top" align="left">
												<xsl:for-each select="*">
													<table>
														<tr>
															<td>
																<xsl:call-template name="editParamOfPort">
																	<xsl:with-param name="predicateName" select="$pName"/>
																	<xsl:with-param name="selectedValue" select="."/>
																</xsl:call-template>
															</td>
															<td valign="top">
																<xsl:if test="document( '/m8/r/r/index.xml' )/*/predicate/*[name()=$pName]">
																	<a href="/m8/{substring(name(),1,1)}/{name()}">q</a>
																</xsl:if>
																
															</td>
															<td valign="top">
																<a href="{$questID}/?a0={name(*)}">x</a>
															</td>
														</tr>
													</table>
												</xsl:for-each>
											</td>
										</tr>
									</xsl:for-each>
								</table>
							</xsl:when>
							<xsl:otherwise>
								<a href="{$questID}/?a0={name($startPort/r/*/*)}">удалить объект</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</td>
				<td align="center" valign="top">
					<div style="padding: 1em; ">
						<xsl:message>!! Правая панель: подсказки значений !!</xsl:message>
						<table cellpadding="3px">
							<xsl:for-each select="exsl:node-set($final_sort)/*">
								<tr>
									<xsl:variable name="predicate" select="name()"/>
									<td valign="top" align="center">
										<a href="{$questID}/?a2={$predicate}" title="популярность: {@count}">
											<xsl:apply-templates select="." mode="titleWord"/>
										</a>
									</td>
								</tr>
							</xsl:for-each>
						</table>
						<br/>Добавление свойства:
			<form action="{$questID}/">
							<select name="a2" onchange="this.form.submit()">
								<!--  class="ajaxInput"-->
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
								<xsl:for-each select="document( '/m8/r/r/predicate_n.xml' )/*/*[name()=$author]/*[name()=$avatar]/*">
									<xsl:variable name="valueName" select="name()"/>
									<xsl:if test="not($startPort[name()=$valueName] or name()=$quest)">
										<option value="{$valueName}">
											<xsl:apply-templates select="." mode="titleWord"/>
										</option>
									</xsl:if>
								</xsl:for-each>
							</select>
						</form>
					</div>
				</td>
			</tr>
		</table>
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
		<!--<xsl:variable name="value_with_this_predicate" select="../ref[@predicate = $predicate]/value"/> //-->
		<xsl:element name="{$value}">
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_value)"/></xsl:attribute>
			<xsl:attribute name="sovpadenie"><xsl:value-of select="$ref_with_this_value_sum_sovp"/></xsl:attribute>
		</xsl:element>
		<xsl:apply-templates select="$ref_with_this_value[last()]/following-sibling::*[1]" mode="value_grouping"/>
	</xsl:template>
	<!--

	-->
</xsl:stylesheet>
