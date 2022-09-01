<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	if(session.getAttribute("loginId") == null){ // 로그인이 안된경우 막기
		response.sendRedirect("./index.jsp?errorMsg=do login"); // index.jsp 재요청
		return;
	}
	session.invalidate(); // 리셋개념 원래있는 세션이 없어지고 새로운 세션을 할당받는다.
	
	// 재요청 index.jsp
	response.sendRedirect("./index.jsp");
%>