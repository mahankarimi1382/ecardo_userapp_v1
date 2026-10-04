import '../widgets/equity_project_card.dart';

/// Comprehensive data models for ECardo Commercial & Equity Crowdfunding
/// (COMM-01).

class ProjectMilestone {
  final String title;
  final String description;
  final String targetDate;
  final bool isCompleted;

  const ProjectMilestone({
    required this.title,
    required this.description,
    required this.targetDate,
    this.isCompleted = false,
  });
}

class ProjectLegalDocument {
  final String id;
  final String title;
  final String fileSize;
  final String fileType;
  final String url;

  const ProjectLegalDocument({
    required this.id,
    required this.title,
    required this.fileSize,
    required this.fileType,
    required this.url,
  });
}

class EquityProjectDetailModel {
  final EquityProjectItem base;
  final String fullDescription;
  final String founderName;
  final String companyRegistrationNo;
  final double valuationAmount;
  final double equityOfferedPercent;
  final double sharePrice;
  final int totalInvestors;
  final List<String> galleryImages;
  final List<ProjectMilestone> milestones;
  final List<ProjectLegalDocument> legalDocuments;
  final Map<String, dynamic> financialHighlights;

  const EquityProjectDetailModel({
    required this.base,
    required this.fullDescription,
    required this.founderName,
    required this.companyRegistrationNo,
    required this.valuationAmount,
    required this.equityOfferedPercent,
    required this.sharePrice,
    required this.totalInvestors,
    required this.galleryImages,
    required this.milestones,
    required this.legalDocuments,
    required this.financialHighlights,
  });
}

class UserInvestmentModel {
  final String investmentId;
  final String projectId;
  final String projectTitle;
  final String sector;
  final double amountInvested;
  final String currency;
  final double shareCount;
  final double expectedYieldPercent;
  final double accumulatedDividends;
  final DateTime investedAt;
  final String status; // active, pending_confirmation, exit_completed

  const UserInvestmentModel({
    required this.investmentId,
    required this.projectId,
    required this.projectTitle,
    required this.sector,
    required this.amountInvested,
    required this.currency,
    required this.shareCount,
    required this.expectedYieldPercent,
    required this.accumulatedDividends,
    required this.investedAt,
    required this.status,
  });
}
