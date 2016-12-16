<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:template match="step[6]">
		<h3>Теплотехнический расчет</h3>
		<div class="res-tit">Теплотехнический расчет строительной системы <span id="i_sys_name_t">
				<xsl:value-of select="$sistemTitle"/>
			</span>
		</div>
	</xsl:template>
</xsl:stylesheet>
