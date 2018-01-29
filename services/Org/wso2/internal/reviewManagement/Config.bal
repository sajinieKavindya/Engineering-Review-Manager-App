package Org.wso2.internal.reviewManagement;

const string configJsonPath = "Config.json";

const string getAllReviewsQuery = "SELECT r.review_id, team_name, product_version, product_name, component_name, component_version, reporter,"
                                  +"review_note, reference, review_date, review_type, participants, e.contributor "+
                                  "FROM Reviews AS r JOIN Contributors AS e ON r.review_id = e.review_id";

const string byDateQuery = " WHERE review_date BETWEEN ? AND ?";
const string byReviewIdQuery = " WHERE r.review_id = ?";
const string byReviewTypeAndDateQuery = " WHERE review_type = ? AND review_date BETWEEN ? AND ?";
const string byTeamNameAndDateQuery = " WHERE team_name = ? AND review_date BETWEEN ? AND ?";
const string byTeamNameContributorAndDateQuery = " WHERE team_name = ? AND e.contributor LIKE ? AND review_date BETWEEN ? AND ?";
const string byReviewNameTypeAndDateQuery = " WHERE team_name = ? AND review_type = ? AND review_date BETWEEN ? AND ?";
const string byReviewNameTypeContributorAndDateQuery = " WHERE team_name = ? AND review_type = ? AND e.contributor  LIKE ? AND review_date BETWEEN ? AND ?";
const string byProductNameAndDateQuery = " WHERE product_name = ? AND review_date BETWEEN ? AND ?";
const string byProductNameContributorAndDateQuery = " WHERE product_name = ? AND e.contributor LIKE ? AND review_date BETWEEN ? AND ?";
const string byProductNameReviewTypeAndDateQuery = " WHERE product_name = ? AND review_type = ? AND review_date BETWEEN ? AND ?";
const string byProductNameReviewTypeContributorAndDateQuery = " WHERE product_name = ? AND review_type = ? AND e.contributor LIKE ? AND review_date BETWEEN ? AND ?";
const string byComponentNameAndDateQuery = " WHERE component_name = ? AND review_date BETWEEN ? AND ?";
const string byComponentNameContributorAndDateQuery = " WHERE component_name = ? AND e.contributor LIKE ? AND review_date BETWEEN ? AND ?";
const string byComponentNameReviewTypeAndDateQuery = " WHERE component_name = ? AND review_type = ? AND review_date BETWEEN ? AND ?";
const string byComponentNameReviewTypeContributorAndDateQuery = " WHERE component_name = ? AND review_type = ? AND e.contributor LIKE ? AND review_date BETWEEN ? AND ?";
const string byContributorAndDateQuery = " WHERE e.contributor LIKE ? AND review_date BETWEEN ? AND ?";
const string byContributorReviewTypeAndDateQuery = " WHERE e.contributor LIKE ? AND review_type = ? AND review_date BETWEEN ? AND ?";

const string getAllTypesQuery = "SELECT * FROM Types";
const string getAllTeamsQueryNew = "SELECT * FROM pqd_area";
const string getAllProductsQueryNew = "SELECT pqd_product_id , pqd_product_name FROM pqd_product";
const string getAllProductsByTeamQueryNew = "SELECT pqd_product_id , pqd_product_name FROM pqd_product WHERE pqd_area_id = ?";

const string insertReviewQueryNew = "INSERT INTO Reviews (team_name, product_version, product_name, component_name, component_version, reporter, review_note, reference, review_date, review_type, participants) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
const string insertContributorsQuery = "INSERT INTO Contributors (contributor, review_id) VALUES (?,?)";
const string getAllContributorsByReviewId = "SELECT contributor FROM Contributors WHERE review_id = ?";