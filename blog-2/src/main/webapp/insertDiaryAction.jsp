<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	// 인코딩
	request.setCharacterEncoding("UTF-8");

	//주소창으로 바로 갈 수 있기 때문에 Action페이지도 막아야한다
	if(session.getAttribute("loginId") == null || (Integer)session.getAttribute("loginLevel") < 1){
		response.sendRedirect("./index.jsp");
		return;
	}

	// 받아오기
	String diaryDate = request.getParameter("diaryDate");
	String diaryTodo = request.getParameter("diaryTodo");
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	String driver = "org.mariadb.jdbc.Driver";
	String url = "jdbc:mariadb://localhost:3306/blog";
	String id = "root";
	String pw = "1234";
	
	// 1. DB 연동
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(url,id,pw);
	// 디버깅
	System.out.println(conn + " <-- conn");


	
	// 2. 쿼리담기
	String sql = "INSERT INTO diary(diary_date, diary_todo, create_date) VALUES (?, ?, now())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	// ? setter
	stmt.setString(1, diaryDate);
	stmt.setString(2, diaryTodo);
	// 디버깅
	System.out.println(stmt + " <-- stmt");


	
	// 3. 쿼리실행
	// 4. 재요청
	int row = stmt.executeUpdate();
	// 디버깅
	if(row == 1){ // insert 성공
		System.out.println("insert 성공!!");
		response.sendRedirect("./diary.jsp");
	} else { // insert 실패
		System.out.println("insert 실패!!");
		response.sendRedirect("./diary.jsp?errorMsg=insert fail");
	}
	
	
	
	
	// 5. 자원해제
	stmt.close();
	conn.close();
%>