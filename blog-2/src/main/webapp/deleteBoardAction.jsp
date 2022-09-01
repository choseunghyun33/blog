<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	//관리자 외 재요청
	if(session.getAttribute("loginLevel") == null // level이 null이거나
		|| (Integer)session.getAttribute("loginLevel") < 0){ // level이 0보다 작다면
		response.sendRedirect("./boardList.jsp?errorMsg=No permission"); // 재요청
		return;
	}
	// 삭제할 boardNo 받아오기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String boardPw = request.getParameter("boardPw");
	// 디버깅
	System.out.println(boardNo + " <-- boardNo");


	// ----------------------------------------------------------- 서비스
	// 1. DB 연동
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://localhost:3306/blog";
	String dbuser = "root";
	String dbpw = "1234";
	Connection conn = DriverManager.getConnection(url, dbuser, dbpw);
	// 디버깅
	System.out.println(conn + " <-- conn");
	
	// 2. 쿼리담기
	// 삭제 deleteStmt
	String deleteSql = "DELETE FROM board WHERE board_no = ? AND board_pw = PASSWORD(?)";
	PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
	// ? setter
	deleteStmt.setInt(1, boardNo);
	deleteStmt.setString(2, boardPw);
	// 디버깅
	System.out.println(deleteStmt + " <-- deleteStmt");
	
	// 3. 쿼리실행 및 재요청
	int row = deleteStmt.executeUpdate();
	// 디버깅
	if(row == 1){ // delete 성공
		System.out.println("삭제성공!!!");
		response.sendRedirect("./boardList.jsp");
	} else { // delete 실패
		System.out.println("삭제실패!!!");
		response.sendRedirect("./boardOne.jsp?boardNo=" + boardNo);
	}
	
	
	// 4. DB자원해제
	deleteStmt.close();
	conn.close();
%>