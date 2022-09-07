<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	// 인코딩
	request.setCharacterEncoding("UTF-8");


	//관리자 외 재요청
	if(session.getAttribute("loginLevel") == null // level이 null이거나
		|| (Integer)session.getAttribute("loginLevel") < 0){ // level이 0보다 작다면
		response.sendRedirect("./boardList.jsp?errorMsg=No permission"); // 재요청
		return;
	}
	

	// ----------------------------------------------------------- 컨트롤러
	// 수정할 boardNo 받아오기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int locationNo = Integer.parseInt(request.getParameter("locationNo"));
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	String boardPw = request.getParameter("boardPw");
	// 디버깅
	System.out.println(boardNo + " <-- boardNo");
	System.out.println(locationNo + " <-- locationNo");
	System.out.println(boardTitle + " <-- boardTitle");
	System.out.println(boardContent + " <-- boardContent");
	System.out.println(boardPw + " <-- boardPw");

	// ----------------------------------------------------------- 서비스
	// 1. DB 연동
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://3.34.240.0:3306/blog";
	String dbuser = "root";
	String dbpw = "1234";
	Connection conn = DriverManager.getConnection(url, dbuser, dbpw);
	// 디버깅
	System.out.println(conn + " <-- conn");
	
	// 2. 쿼리담기
	// 수정 updateStmt
	String updateSql = "UPDATE board SET location_no = ?, board_title = ?, board_content = ? WHERE board_no = ? AND board_pw = PASSWORD(?)";
	PreparedStatement updateStmt = conn.prepareStatement(updateSql);
	// ? setter
	updateStmt.setInt(1, locationNo);
	updateStmt.setString(2, boardTitle);
	updateStmt.setString(3, boardContent);
	updateStmt.setInt(4, boardNo);
	updateStmt.setString(5, boardPw);
	// 디버깅
	System.out.println(updateStmt + " <-- updateStmt");
	
	// 3. 쿼리실행
	int row = updateStmt.executeUpdate();
	// 디버깅
	if(row == 1){ // update 성공
		System.out.println("수정성공!!!");
	} else { // update 실패
		System.out.println("수정실패!!!");
	}
	
	
	// 4. 재요청
	response.sendRedirect("./boardOne.jsp?boardNo=" + boardNo);
	
	// 5. DB자원해제
	updateStmt.close();
	conn.close();
%>